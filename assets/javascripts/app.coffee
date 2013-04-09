$(document).ready ->    
  $dropArea = $('#drop-area')
  $uploadLink = $dropArea.find('.upload-link-wrapper > h2')
  $filePickerButton = $('#file-picker-button')
  $photoCollection = $('#photo-collection')

  jQuery.event.props.push('dataTransfer')

  $dropArea.on 'dragenter dragover dragleave dragend drop', (e) ->
    if $(this).hasClass('hidden')
      e.stopImmediatePropagation()

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

  handleSelectedFiles = (files) ->
    hideDropArea()

    # $photoCollection.css width: $photoCollection.width()

    for file in files
      fileReader = new FileReader()

      fileReader.onload = (e) ->
        $photo = $('<div class="photo"><img /><h3></h3></div>')
        $img = $photo.find('img')
        $title = $photo.find('h3')

        $img.attr src: e.target.result
        angle = Math.random() * 4 - 2
        
        $title.text(file.name)

        $photo.css WebkitTransform: "rotate(#{angle}deg)"

        $photoCollection.find('.photos-wrapper').append $photo

        # TODO: tekenen op canvas element ...

        $img.on 'load', ->
          resizeToFit $(this), 360, 270
    
      fileReader.readAsDataURL(file)

  hideDropArea = ->
    $dropArea.animate left: (20 - $dropArea.width()), right: ($dropArea.width() - 20), 200, ->
      $(this).addClass('hidden').click -> showDropArea()
      $dropArea.css right: 'auto', width: $dropArea.width()      

  showDropArea = ->
    if $dropArea.hasClass 'hidden'
      $dropArea.css right: ($dropArea.width() - 20), width: 'auto'
      $dropArea.animate left: 10, right: 10, 200, ->
        $(this).removeClass('hidden')
        $photoCollection.find('.photos-wrapper').html('')

  resizeToFit = ($image, max_width, max_height) ->
    horizontal_ratio = $image.width() / max_width
    vertical_ratio = $image.height() / max_height

    if horizontal_ratio > vertical_ratio
      $image.height ($image.height() / horizontal_ratio)
      $image.width max_width
    else
      $image.width ($image.width() / vertical_ratio)
      $image.height max_height
    


