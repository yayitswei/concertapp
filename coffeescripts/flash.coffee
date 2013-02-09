faye = new Faye.Client('http://localhost:5000/faye')

flash = ->
  $body = $('body')
  $body.addClass('on')
  setTimeout( ->
    $body.removeClass('on')
  , 20)

faye.subscribe '/flash', (timestamp) ->
  now = window.getSyncTime()
  if timestamp > now
    setTimeout(flash, timestamp - now)

window.publishFlash = (timestamp) ->
  faye.publish('/flash', timestamp)
