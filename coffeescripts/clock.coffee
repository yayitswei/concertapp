serverTimeDifference = 0
lastServerTime = 0
lastRtt = 0
shortestRtt = undefined

syncClock = ->
  start = Date.now()
  xhr = $.getJSON('/time.json?t=' + start)
  xhr.done (response) ->
    strobePeriod = 60 * 1000 / parseFloat(response['bpm'])

    clientTimeNow = Date.now()
    lastRtt = (clientTimeNow - start)

    # Don't bother with a less accurate time
    return if shortestRtt && shortestRtt < lastRtt

    shortestRtt = lastRtt
    lastServerTime = parseFloat(response['time']) * 1000
    serverTimeNow = lastServerTime + lastRtt/2
    difference = serverTimeNow - clientTimeNow

    # If the rtt is as high as the difference, the estimate probably isn't 
    # precise enough to be useful.
    #return if Math.abs(difference) < lastRtt

    serverTimeDifference = difference
    shortestRtt = lastRtt

syncClock()
setInterval(syncClock, 5000)

window.getSyncTime = ->
  Date.now() - serverTimeDifference
