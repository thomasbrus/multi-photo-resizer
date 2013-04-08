$(document).ready ->    
  $dropArea = $('#drop-area')
  $uploadLink = $dropArea.find('.upload-link-wrapper > h2')
  $filePickerButton = $('#file-picker-button')

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

  $filePickerButton.change ->
    setTimeout =>
      handleSelectedFiles this.files
    , 300

  handleSelectedFiles = (files) ->
    hideDropArea()    

    for file in files
      fileReader = new FileReader()

      fileReader.onload = (e) ->
        console.log e.target.result
    
      fileReader.readAsDataURL(file)

  hideDropArea = ->
    $dropArea.animate left: (20 - $dropArea.width()), right: ($dropArea.width() - 20), opacity: 0.5, 200, ->
      $(this).addClass('hidden').click -> showDropArea()

  showDropArea = ->
    if $dropArea.hasClass 'hidden'
      $dropArea.css right: ($dropArea.width() - 20), width: 'auto'
      $dropArea.animate left: 10, right: 10, opacity: 1.0, 200, -> $(this).removeClass('hidden')