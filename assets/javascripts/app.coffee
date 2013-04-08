$(document).ready ->  
  jQuery.event.props.push('dataTransfer')
  
  $dropArea = $('#drop-area')

  $dropArea.on 'dragenter dragover', ->
    $(this).addClass 'dragover'
    return false

  $dropArea.on 'dragleave dragend drop', ->
    $(this).removeClass 'dragover'
    return false

  $dropArea.on 'drop', (e) ->    
    handleFiles e.dataTransfer.files
    return false

  $uploadLink = $dropArea.find('.upload-link-wrapper > h2')
  $filePickerButton = $('#file-picker-button')
  
  $uploadLink.mousemove (e) ->  
    $filePickerButton.css 'left', (e.pageX - $(this).offset().left - $filePickerButton.width() + 40)
    $filePickerButton.css 'top', (e.pageY - $(this).offset().top - 10)

  $filePickerButton.change ->
    handleFiles this.files

handleFiles = (files) ->
  console.log files
