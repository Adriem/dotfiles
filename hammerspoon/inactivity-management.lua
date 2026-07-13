-- =============================================================================
--  Shortcuts for managing idle state
--
--  In order to enable this module, just require it
--  from init.lua file inside ~/.hammerspoon/ folder
--
--  author: Adrian Moreno
-- =============================================================================

im = {}

function im.onIdleDetected(idleTimeSeconds, pollingTimeSeconds, handleIdleDetected)
  hs.timer.doEvery(pollingTimeSeconds, function()
    if (hs.host.idleTime() >= idleTimeSeconds) then handleIdleDetected() end
  end)
end

function im.withWarning(warning_msg, exec)
  local alertUuid = hs.alert.show(warning_msg, {
    strokeWidth  = 4,
    strokeColor = { red = 1, green = 1, blue = 0, alpha = 1 },
    fillColor   = { white = 0, alpha = 0.75 },
    textColor = { red = 1, green = 1, blue = 0, alpha = 1 },
    textFont  = ".AppleSystemUIFont",
    textSize  = 37,
    radius = 27,
    atScreenEdge = 0,
    fadeInDuration = 0.15,
    fadeOutDuration = 0.15,
    padding = 40,
  })
  exec(function()
    hs.alert.closeSpecific(alertUuid)
  end)
end

