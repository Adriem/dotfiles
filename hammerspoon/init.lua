-- require('keyboard-management')


-- --=[ WINDOW MANAGEMENT ]=----------------------------------------------------

require('window-management')

wm.setWindowAnimation(0)

local snap_window_left = wm.cycleSnapWindow({
  wm.leftSnap(0.5),
  wm.leftSnap(0.6),
  wm.leftSnap(0.7),
--  wm.leftSnap(0.15),
  wm.leftSnap(0.3),
  wm.leftSnap(0.4)
})

local snap_window_right = wm.cycleSnapWindow({
  wm.rightSnap(0.5),
  wm.rightSnap(0.6),
  wm.rightSnap(0.7),
--  wm.rightSnap(0.15),
  wm.rightSnap(0.3),
  wm.rightSnap(0.4)
})

local snap_window_center = wm.cycleSnapWindow({
  wm.maximized(true),
  wm.centerSnap(0.95, 0.95),
  wm.centerSnap(0.85, 0.95),
  wm.centerSnap(0.65, 0.95),
  wm.centerSnap(0.65, 0.75),
  wm.centerSnap(0.4, 0.75),
  wm.centerSnap(0.4, 0.65),
  wm.maximized(false)
})

local snap_window_vertical = wm.cycleSnapWindow({
  wm.verticalSnap(0, 1),
  wm.verticalSnap(0, 0.5),
  wm.verticalSnap(0, .65),
  wm.verticalSnap(0.5, 0.5),
  wm.verticalSnap(0.65, 0.35)
})

local move_window_north_screen = wm.moveToScreen('north')
local move_window_south_screen = wm.moveToScreen('south')
local move_window_east_screen = wm.moveToScreen('east')
local move_window_west_screen = wm.moveToScreen('west')


-- --=[ KEY BINDINGS ]=--------------------------------------------------------

-- Snap a window to a grid on the active screen
hs.hotkey.bind({'cmd', 'ctrl'}, 'h', snap_window_left)
hs.hotkey.bind({'cmd', 'ctrl'}, 'j', snap_window_vertical)
hs.hotkey.bind({'cmd', 'ctrl'}, 'k', snap_window_center)
hs.hotkey.bind({'cmd', 'ctrl'}, 'l', snap_window_right)

hs.hotkey.bind({'cmd', 'shift', 'ctrl'}, 'h', move_window_west_screen)
hs.hotkey.bind({'cmd', 'shift', 'ctrl'}, 'j', move_window_south_screen)
hs.hotkey.bind({'cmd', 'shift', 'ctrl'}, 'k', move_window_north_screen)
hs.hotkey.bind({'cmd', 'shift', 'ctrl'}, 'l', move_window_east_screen)

-- --=[ IDLE BEHAVIOUR ]-------------------------------------------------------

require('inactivity-management')
require('slack-utils')

local channels = {'#alertsckbot-data', '#alerts-web', '#app-reviews', '#support-operations'}
local channelIdx = 1

im.onIdleDetected(25 * 60, 5 * 60, function()
  im.withWarning("PLEASE, STAND BY", function(closeAlert)
    slack.launchOrFocus()
    channelIdx = channelIdx % #channels + 1
    slack.asyncOpenChannel(channels[channelIdx], closeAlert)
  end)
end)

