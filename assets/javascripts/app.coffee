$(document).ready ->    
  $dropArea = $('#drop-area')
  $uploadLink = $dropArea.find('.upload-link-wrapper > h2')
  $filePickerButton = $('#file-picker-button')
  $photoCollection = $('#photo-collection')
  $resizePhotosButton = $('#resize-photos-button')
  $settingsBar = $('#settings-bar')
  $ratioSlider = $settingsBar.find('.ratio-slider')

  jQuery.event.props.push('dataTransfer')

  selectedPhotos = []
  ratioSliderHandlePressed = false

  $settingsBar.slideUp(0)

  $dropArea.on 'dragenter dragover', ->    
    $(this).addClass 'dragover'
    return false

  $dropArea.on 'dragleave dragend drop', ->
    $(this).removeClass 'dragover'
    return false

  $dropArea.on 'drop', (e) ->    
    handleSelectedFiles e.dataTransfer.files
    return false
  
  $uploadLink.mousemove (e) ->  
    $filePickerButton.css 'left', (e.pageX - $(this).offset().left - $filePickerButton.width() + 40)
    $filePickerButton.css 'top', (e.pageY - $(this).offset().top - 10)

  $filePickerButton.on 'change', ->
    setTimeout =>
      handleSelectedFiles this.files
    , 500

  $(window).mousemove (e) ->
    if ratioSliderHandlePressed
      $handle = $ratioSlider.find('.handle')
      $percentage = $ratioSlider.find('.percentage')

      offset = e.pageX - $ratioSlider.offset().left - 40
      # step = ($ratioSlider.find('.middle').width()) / 10
      # offset = Math.round(offset / step) * step
      offset = Math.min($ratioSlider.width() - 50, Math.max(-10, offset))
      percentage = Math.round((offset + 10) / ($ratioSlider.find('.middle').width()) * 100)

      $handle.css left: (offset - 10)
      $percentage.css width: (offset + 10)
      $ratioSlider.data percentage: percentage
      $settingsBar.find('#percentage').text percentage + '%'
      
      $('body').addClass 'dragging'

  $ratioSlider.find('.handle').mousedown (e) ->
    ratioSliderHandlePressed = true
    $ratioSlider.find('.handle').addClass 'active'
    e.originalEvent.preventDefault()

  $(window).mouseup ->
    ratioSliderHandlePressed = false
    $('body').removeClass 'dragging'
    $ratioSlider.find('.handle').removeClass 'active'

  $(window).resize ->
    resizeRatioSlider()

  resizeRatioSlider = ->
    $handle = $ratioSlider.find('.handle')
    $percentage = $ratioSlider.find('.percentage')

    width = parseInt($settingsBar.width()) - 400
    percentage = $ratioSlider.data('percentage')

    $ratioSlider.find('.middle').css width: width

    offset = ($ratioSlider.find('.middle').width() * (percentage / 100)) - 20

    $handle.css left: offset
    $percentage.css width: (offset + 20)

  $ratioSlider.data percentage: 100
  resizeRatioSlider()

  $resizePhotosButton.click ->
    $canvas = $('#rendering-canvas')
    context = $canvas[0].getContext('2d')
    percentage = $ratioSlider.data('percentage')

    zip = new JSZip()
    imagesFolder = zip.folder('images')

    for photo in selectedPhotos
      [originalWidth, originalHeight] = photo.original_dimension

      resizedWidth = originalWidth * (percentage / 100)
      resizedHeight = originalHeight * (percentage / 100)

      $canvas.attr width: resizedWidth, height: resizedHeight
      $canvas[0].width = resizedWidth
      $canvas[0].height = resizedHeight

      context.drawImage(photo.$img[0], 0, 0, resizedWidth, resizedHeight)
      data_uri = $canvas[0].toDataURL('image/jpeg')

      data = data_uri.substring(data_uri.indexOf(',') + 1)
      imagesFolder.file(photo.filename, data, base64: true)
    
    content = zip.generate()
    blob = dataToBlob(content, 'application/zip')
    location.href = webkitURL.createObjectURL(blob)

  dataToBlob = (data, type) ->
    binary = atob(data)
    bytes = []
    i = 0
    
    while i < binary.length
      bytes.push(binary.charCodeAt(i))
      i++  
    
    new Blob([new Uint8Array(bytes)], type: type)

  handleSelectedFiles = (files) ->
    files = (file for file in files when file.type[0..5] == "image/")
    return if files.length == 0

    unless $dropArea.hasClass 'hidden'
      hideDropArea() 
      showResizePhotosButton()

    prependPhotos = false # $photoCollection.find('.photos-wrapper .photo').length > 0    

    for file in files  
      fileReader = new FileReader()

      $photo = $('<div class="photo">
        <img />
        <h3><abbr></abbr></h3>
      </div>')
      
      if prependPhotos
        $photoCollection.find('.photos-wrapper').prepend $photo
      else
        $photoCollection.find('.photos-wrapper').append $photo
      
      $photo.css visibility: 'hidden'

      fileReader.onload = ((file, $photo) ->
        (e) ->
          $img = $photo.find('img')
          $title = $photo.find('h3')

          $img.attr src: e.target.result
          angle = Math.random() * 3 - 1.5

          $title.attr title: file.name
          $title.find('abbr').attr(title: file.name)
          
          $photo.css WebkitTransform: "rotate(#{angle}deg)"

          $img.on 'load', ->
            selectedPhotos.push {
              filename: file.name,
              data_uri: e.target.result,
              $img: $(this),
              original_dimension: [$(this).width(), $(this).height()]
            }
            resizeToFit $(this), 360, 270
            replaceImgWithCanvas $(this)
            $title.haircut(placement: 'middle');

            setTimeout (=>
              $photo.css(visibility: 'visible').hide().fadeIn(300)
            ), 0
      )(file, $photo)

      setTimeout ((file, fileReader) ->
        -> fileReader.readAsDataURL(file)
      )(file, fileReader), 250

  hideDropArea = ->
    $dropArea.animate left: (30 - $dropArea.width()), right: ($dropArea.width() - 30), 200, ->
      $(this).addClass('hidden')

      $(this).click ->        
        showDropArea()
        hideResizePhotosButton()

      $(this).hover (->
        $(this).css borderStyle: 'solid', cursor: 'pointer'
      ), (->
        $(this).css borderStyle: 'dashed', cursor: 'auto'
      )

      $dropArea.css right: 'auto', width: $dropArea.width()      

  showDropArea = ->
    if $dropArea.hasClass 'hidden'
      $dropArea.css right: ($dropArea.width() - 30), width: 'auto'
      $dropArea.animate left: 10, right: 10, 200, ->
        $(this).removeClass('hidden').trigger('mouseleave').off('mouseenter mouseleave click')
        clearPhotoCollection()

  resizeToFit = ($image, max_width, max_height) ->
    horizontal_ratio = $image.width() / max_width
    vertical_ratio = $image.height() / max_height

    if horizontal_ratio > vertical_ratio
      $image.attr height: ($image.height() / horizontal_ratio)
      $image.attr width: max_width
    else
      $image.attr width: ($image.width() / vertical_ratio)
      $image.attr height: max_height
    
  clearPhotoCollection = ->
    $photoCollection.find('.photos-wrapper').html('')
    selectedPhotos = []

  showResizePhotosButton = ->
    $settingsBar.slideDown(250)

  hideResizePhotosButton = ->
    # $settingsBar.slideUp(250)
    $settingsBar.slideUp(0)

  replaceImgWithCanvas = ($img) ->
    width = $img.width()
    height = $img.height()

    $canvas = $('<canvas width="' + width + '" height="' + height + '"></canvas>')
    $canvas.insertAfter($img)

    context = $canvas[0].getContext('2d')
    context.drawImage($img[0], 0, 0, width, height)