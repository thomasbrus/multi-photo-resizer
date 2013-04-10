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
      offset = Math.min($ratioSlider.width() - 60, Math.max(-20, offset))
      percentage = (offset + 20) / ($ratioSlider.find('.middle').width()) * 100

      $handle.css left: offset
      $percentage.css width: (offset + 20)
      $ratioSlider.data percentage: percentage
      $settingsBar.find('#percentage').text Math.round(percentage) + '%'
      
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

    width = parseInt($settingsBar.width()) - 371
    percentage = $ratioSlider.data('percentage')

    $ratioSlider.find('.middle').css width: width

    offset = ($ratioSlider.find('.middle').width() * (percentage / 100)) - 20

    $handle.css left: offset
    $percentage.css width: (offset + 20)

  $ratioSlider.data percentage: 100
  resizeRatioSlider()

  $resizePhotosButton.click ->
    # zip = new JSZip()
    # imagesFolder = zip.folder("images")

    # for photo in selectedPhotos      
    #   data = photo.data_uri.substring(photo.data_uri.indexOf(',') + 1)
    #   console.log "Adding #{photo.filename} of size #{data.length} bytes"
    #   console.log "Start of data uri: ", photo.data_uri[0..40]
    #   console.log "Start of data: ", data[0..40]
    #   imagesFolder.file(photo.filename, data, base64: true)

    # content = zip.generate()
    # location.href = "data:application/zip;base64," + content

    # byteArray = new Uint8Array(content.length)

    # i = 0

    # while i < content.length
    #   byteArray[i] = String.fromCharCode(content.charCodeAt(i) & 0xff)
    #   i++


    # blob = new Blob([content], type: 'application/zip')    
    # location.href = webkitURL.createObjectURL(blob)

  handleSelectedFiles = (files) ->
    files = (file for file in files when file.type[0..5] == "image/")
    return if files.length == 0

    unless $dropArea.hasClass 'hidden'
      hideDropArea() 
      showResizePhotosButton()

    # $photoCollection.css width: $photoCollection.width()
    prependPhotos = $photoCollection.find('.photos-wrapper .photo').length > 0

    for file in files  
      fileReader = new FileReader()

      fileReader.onload = ((file) ->
        (e) ->
          selectedPhotos.push filename: file.name, data_uri: e.target.result

          $photo = $('<div class="photo">
            <img />
            <h3><abbr></abbr></h3>
          </div>')

          $img = $photo.find('img')
          $title = $photo.find('h3')

          $img.attr src: e.target.result
          angle = Math.random() * 3 - 1.5

          $title.attr title: file.name
          $title.find('abbr').attr(title: file.name)
          
          $photo.css WebkitTransform: "rotate(#{angle}deg)"
          
          if prependPhotos
            $photoCollection.find('.photos-wrapper').prepend $photo
          else
            $photoCollection.find('.photos-wrapper').append $photo

          # TODO: tekenen op canvas element ...

          $img.on 'load', ->
            resizeToFit $(this), 360, 270
            $title.haircut(placement: 'middle');
      )(file)

      setTimeout ((file, fileReader) ->
        -> fileReader.readAsDataURL(file)
      )(file, fileReader), 200

  hideDropArea = ->
    $dropArea.animate left: (30 - $dropArea.width()), right: ($dropArea.width() - 30), 200, ->
      $(this).addClass('hidden').click ->
        showDropArea(); hideResizePhotosButton()
      $dropArea.css right: 'auto', width: $dropArea.width()      

  showDropArea = ->
    if $dropArea.hasClass 'hidden'
      clearPhotoCollection()
      $dropArea.css right: ($dropArea.width() - 30), width: 'auto'
      $dropArea.animate left: 10, right: 10, 200, ->
        $(this).removeClass('hidden')

  resizeToFit = ($image, max_width, max_height) ->
    horizontal_ratio = $image.width() / max_width
    vertical_ratio = $image.height() / max_height

    if horizontal_ratio > vertical_ratio
      $image.height ($image.height() / horizontal_ratio)
      $image.width max_width
    else
      $image.width ($image.width() / vertical_ratio)
      $image.height max_height
    
  clearPhotoCollection = ->
    $photoCollection.find('.photos-wrapper').html('')
    selectedPhotos = []

  showResizePhotosButton = ->
    $settingsBar.slideDown(250)

  hideResizePhotosButton = ->
    $settingsBar.slideUp(150)