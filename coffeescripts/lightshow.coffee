$.getJSON '/playback_token.json', (response) ->
  playbackToken = response['playbackToken']
  console.log("received playback token: " + playbackToken)

  $player = $('#player')
  $player.rdio(playbackToken)

  $player.bind 'ready.rdio', ->
    $(this).rdio().play('a171827')

  #$player.bind 'positionChanged.rdio', (position) ->
  #  console.log(position)
