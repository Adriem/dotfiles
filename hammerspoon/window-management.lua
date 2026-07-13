-- =============================================================================
--  Shortcuts for managing windows and window layouts.
--
--  In order to enable this module, just require it
--  from init.lua file inside ~/.hammerspoon/ folder
--
--  author: Adrian Moreno
-- =============================================================================

wm = {}

function wm.setWindowAnimation(level)
  hs.window.animationDuration = level
end


function wm.leftSnap(width)
  return {
    x = 0,
    y = 0,
    w = width,
    h = 1,
    padding = true
  }
end

function wm.rightSnap(width)
  return {
    x = 1 - width,
    y = 0,
    w = width,
    h = 1,
    padding = true
  }
end

function wm.centerSnap(width, height)
  return {
    x = (1 - width) / 2,
    y = (1 - height) / 2,
    w = width,
    h = height,
    padding = true
  }
end

function wm.verticalSnap(y, height)
  return {
    y = y,
    h = height,
    padding = true
  }
end

function wm.horizontalSnap(x, width)
  return {
    x = x,
    w = width,
    padding = true
  }
end

function wm.maximized(padding)
  return {
    x = 0,
    y = 0,
    w = 1,
    h = 1,
    padding = padding or false
  }
end


function wm.cycleSnapWindow(snapList)
  local actionList = snapList or {}

  return function()
    local frame = hs.screen.mainScreen():frame()
    local window = hs.window.focusedWindow()

    local snapIdx = 1  -- Indexes in Lua are 1-based

    while snapIdx < #snapList and (
        not isWindowSnapped(window, snapList[snapIdx], frame)
        or isWindowSnapped(window, snapList[snapIdx % #snapList + 1], frame)
    ) do
      snapIdx = snapIdx + 1
    end

    snapIdx = snapIdx % #snapList + 1

    snapWindow(window, snapList[snapIdx], frame)
  end
end

function wm.moveToScreen(direction)
  -- direction = 'north' | 'south' | 'east' | 'west' (case insensitive)
  return function()
    -- -- Check if window was `snapped`
    -- local snapAction = nil
    -- for actionName, actionList in pairs(actions) do
    --   if actionName:sub(1,4) == 'snap' then
    --     snapAction = hs.fnutils.find(actionList, function(action)
    --       return action.test()
    --     end)
    --   end
    -- end

    -- Move window
    local targetWindow = hs.window.focusedWindow()
    local functionName = ('moveOneScreen'
                           ..direction:sub(1,1):upper()
                           ..direction:sub(2):lower())

    targetWindow[functionName](targetWindow, false, true)
    if snapAction then snapAction.exec() end
  end
end


function isWindowSnapped(window, position, frame)
  -- Check if a window is snapped to the given position.
  local targetPosition = calculatePosition(position, window, frame)
  local isMatch = match(window, targetPosition)

  return isMatch
end


function snapWindow(window, position, frame)
  -- Move the window to the target relative position
  local targetPosition = calculatePosition(position, window, frame)

  window:move(targetPosition, window)
  correctPosition(window, frame, position.padding)

  if not match(window, targetPosition) then
    snapExceptions.set(window:id(), targetPosition, window:frame())
  end
end


function calculatePosition(position, window, frame)
  local windowFrame = window:frame()
  local gutterWidth = getGutterWidth()

  local targetPosition;
  targetPosition = translate(position, frame)
  if position.padding then targetPosition = pad(targetPosition, gutterWidth, frame) end

  return {
    x = targetPosition.x or math.max(windowFrame.x, frame.x + gutterWidth),
    y = targetPosition.y or math.max(windowFrame.y, frame.y + gutterWidth),
    w = targetPosition.w or math.min(windowFrame.w, frame.w - 2 * gutterWidth),
    h = targetPosition.h or math.min(windowFrame.h, frame.h - 2 * gutterWidth)
  }
end



function translate(units, frame)
  -- Translate relative units to an actual position on a frame
  return {
    x = units.x and (units.x * frame.w + frame.x),
    y = units.y and (units.y * frame.h + frame.y),
    w = units.w and (units.w * frame.w),
    h = units.h and (units.h * frame.h)
  }
end


function pad(rect, padding, frame)
  -- Add padding to a rectangle, overlapping it if necessary
  local paddingLeft   = rect.x and rect.w and  math.ceil(padding * (rect.x > frame.x and .5 or 1))
  local paddingRight  = rect.x and rect.w and math.floor(padding * (rect.x + rect.w < frame.x + frame.w and .5 or 1))
  local paddingTop    = rect.y and rect.h and  math.ceil(padding * (rect.y > frame.y and .5 or 1))
  local paddingBottom = rect.y and rect.h and math.floor(padding * (rect.y + rect.h < frame.y + frame.h and .5 or 1))

  return {
    x = rect.x and rect.x + paddingLeft,
    y = rect.y and rect.y + paddingTop,
    w = rect.w and rect.w - (paddingLeft + paddingRight),
    h = rect.h and rect.h - (paddingTop + paddingBottom)
  }
end


function match(window, pos)
  -- Check if a window matches given position
  local windowFrame = window:frame()
  local expectedPosition = snapExceptions.get(window:id(), pos) or pos

  return windowFrame:equals(expectedPosition)
end


snapExceptions = (function()
  local snapExceptions = {}

  function positionToId(positionUnits)
    local re= string.format("%1.3f-%1.3f-%1.3f-%1.3f-%d",
      positionUnits.x, positionUnits.y, positionUnits.w, positionUnits.h,
      hs.screen.mainScreen():id())
    return re
  end

  return {
    set = (function(windowId, expectedPos, actualPos)
      snapExceptions[windowId] = snapExceptions[windowId] or {}
      snapExceptions[windowId][positionToId(expectedPos)] = actualPos
    end),
    get = (function(windowId, expectedPos)
      return (snapExceptions[windowId]
        and snapExceptions[windowId][positionToId(expectedPos)])
    end)
  }
end)()


function correctPosition(window, frame, hasPadding)
  -- If a window did not snap properly, correct its position
  local windowFrame = window:frame()
  local padding = getGutterWidth()

  local newPosition = windowFrame:copy()
  local applyCorrections = false

  local maxWidth = frame.x + frame.w - windowFrame.x - (hasPadding and padding or 0)
  if windowFrame.w > maxWidth then
    applyCorrections = true
    newPosition.x = frame.x + frame.w - windowFrame.w - (hasPadding and padding or 0)
  end

  local maxHeight = frame.y + frame.h - windowFrame.y - (hasPadding and padding or 0)
  if windowFrame.h > maxHeight then
    applyCorrections = true
    newPosition.y = frame.y + frame.h - windowFrame.h - (hasPadding and padding or 0)
  end


  if applyCorrections then window:move(newPosition) end
end


function getGutterWidth()
  -- Calculate the size of the gutter, which is the 5% of the screen diagonal
  local screenFrame = hs.screen.mainScreen():frame()
  local screenDiagonal = math.sqrt((screenFrame.w ^ 2) + (screenFrame.h ^ 2))
  local gutterWidth = math.ceil(screenDiagonal * .005)

  return gutterWidth
end


-- ---===[ MOVE HELPERS ]===----------------------------------------------------

function config(bindings, actions)

  bindings = {

    -- Move a window to an adjacent screen
    moveToNorthScreen = {{"cmd", "ctrl", "shift"}, "k"},
    moveToSouthScreen = {{"cmd", "ctrl", "shift"}, "j"},
    moveToEastScreen  = {{"cmd", "ctrl", "shift"}, "l"},
    moveToWestScreen  = {{"cmd", "ctrl", "shift"}, "h"}
  }

  actions = {

    -- Move a window to an adjacent screen
    moveToNorthScreen = { moveToScreen('north') },
    moveToSouthScreen = { moveToScreen('south') },
    moveToEastScreen = { moveToScreen('east') },
    moveToWestScreen = { moveToScreen('west') }
  }

  -- For each action binding, cycle through available actions
  for actionName,binding in pairs(bindings) do
    local actionList = actions[actionName] or {}

    local cycleActionsHandler = function()
      local actionIdx = 1  -- Indexes in Lua are 1-based
      while actionIdx < #actionList and not actionList[actionIdx].test() do
        actionIdx = actionIdx + 1
      end
      actionIdx = actionIdx % #actionList + 1

      actionList[actionIdx].exec()
    end

    hs.hotkey.bind(binding[1], binding[2], cycleActionsHandler)
  end
end


function moveToScreen(direction)
  -- direction = 'north' | 'south' | 'east' | 'west' (case insensitive)
  return {
    test = (function() return false end),
    exec = (function()
      -- Check if window was `snapped`
      local snapAction = nil
      for actionName, actionList in pairs(actions) do
        if actionName:sub(1,4) == 'snap' then
          snapAction = hs.fnutils.find(actionList, function(action)
            return action.test()
          end)
        end
      end

      -- Move window
      local functionName = ('moveOneScreen'
                             ..direction:sub(1,1):upper()
                             ..direction:sub(2):lower())

      hs.window[functionName](hs.window.focusedWindow(), false, true)
      if snapAction then snapAction.exec() end
    end)
  }
end


-- ---===[ SETUP ]===-----------------------------------------------------------

-- config()
