-- =============================================================================
--  Utilities for managing the Slack app
--
--  In order to enable this module, just require it
--  from init.lua file inside ~/.hammerspoon/ folder
--
--  author: Adrian Moreno
-- =============================================================================

local SLACK_APP_NAME = "Slack"

slack = {}

slack.launchOrFocus = function()
  hs.application.launchOrFocus(SLACK_APP_NAME)

  return hs.window.focusedWindow()
end

slack.asyncOpenChannel = function(channel_name, onComplete)
  hs.eventtap.keyStroke({"cmd"}, "K")
  hs.timer.doAfter(1, function()
    hs.eventtap.keyStrokes(channel_name)
    hs.eventtap.keyStroke({}, "return")
    onComplete()
  end)
end
