$ ->
  $player = $('#player')
  rdio = undefined

  # This is War
  #rdioId = 't2410510'

  # Kings and Queens
  rdioId = 't2410365'

  nextIndexToSchedule = 0
  echonest = undefined

  $('a.play').click ->
    rdio.play(rdioId, initialPosition: 60.0)
    nextIndexToSchedule = 0
    false

  $('a.pause').click ->
    rdio.pause()
    false

  getBeat = (index) ->
    echonest['tatums'][index]

  getFlashStart = (index) ->
    nudge = window.nudge || 0.0
    getBeat(index).start + nudge

  $player.bind 'positionChanged.rdio', (event, position) ->
    $('.position').text(position)
    beatStart = getFlashStart(nextIndexToSchedule)

    now = window.getSyncTime()

    while beatStart < position + 10.0
      if nextIndexToSchedule % 2 == 0
        if beatStart > position
          publishFlash(now + (beatStart - position) * 1000)

      nextIndexToSchedule++;

      beatStart = getFlashStart(nextIndexToSchedule)

    $('.confidence').text(getBeat(nextIndexToSchedule)['confidence'])
    $('.index').text(nextIndexToSchedule)

    undefined

  $.getJSON '/playback_token.json', (response) ->
    playbackToken = response['playbackToken']
    console.log("received playback token: " + playbackToken)

    rdio = $player.rdio(playbackToken)

    $player.bind 'ready.rdio', ->
      console.log('rdio ready')

    undefined

  $.getJSON '/echonest_profile.json', {rdio_id: rdioId}, (response) ->
    console.log('echonest ready')
    echonest = response
    window.echonest = echonest
    undefined
