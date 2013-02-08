$.getJSON '/playback_token.json', (response) ->
  $('#player').rdio(response['playbackToken'])
  $('#player').bind 'ready.rdio', ->
    $(this).rdio().play('a171827')
