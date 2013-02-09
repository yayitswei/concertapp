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
    rdio.play(rdioId, initialPosition: 220.0)
    nextIndexToSchedule = 0
    false

  $('a.pause').click ->
    rdio.pause()
    false

  flash = ->
    $body = $('body')
    $body.addClass('on')
    setTimeout( ->
      $body.removeClass('on')
    , 20)


  getBeat = (index) ->
    echonest['beats'][index]

  getFlashStart = (index) ->
    nudge = window.nudge || 0.0
    getBeat(index).start + nudge

  $player.bind 'positionChanged.rdio', (event, position) ->
    $('.position').text(position)
    beatStart = getFlashStart(nextIndexToSchedule)

    while beatStart < position + 2.0
      if beatStart > position
        if nextIndexToSchedule % 2 == 1
          setTimeout(flash, (beatStart - position) * 1000)

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
    console.log(response)
    echonest = response
    window.echonest = echonest
    undefined
