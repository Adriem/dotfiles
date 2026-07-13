local US       = 'U.S.'
local US_INTER = 'U.S. International - PC'

local config = {
  ['iTerm2'] = US,
  ['IntelliJ IDEA'] = US
}

local default = US_INTER

function handleAppWatcher (appName, eventType, app)
  if (eventType == hs.application.watcher.launched
      or eventType == hs.application.watcher.activated) then
    hs.keycodes.setLayout(config[appName] or default);
  end
end

hs.application.watcher.new(handleAppWatcher):start()
