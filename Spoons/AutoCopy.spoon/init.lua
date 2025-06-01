-- extended implementation shown here: https://github.com/Hammerspoon/hammerspoon/issues/2196
AutoCopy = dofile(hs.spoons.resourcePath("lib/autoCopy.lua"))

local _spoon = {}
_spoon.__index = _spoon

_spoon.name = "AutoCopy"
_spoon.version = "1.1"
_spoon.author = "Robert Reed"
_spoon.homepage = "https://github.com/Hammerspoon/Spoons"
_spoon.license = "MIT - https://opensource.org/licenses/MIT"

--- spoon.AutoCopy:start(config)
--- Method
--- Start AutoCopy
---
--- Parameters:
---  * config = {
---    skipIDs = {
---      "budleID1",
---      "budleID2",
---    }
---  }
function _spoon:start(config)
	AutoCopy:start(config)
end

--- spoon.AutoCopy:stop()
--- Method
--- stop AutoCopy
---
--- Parameters:
---  * None
function _spoon:stop()
	AutoCopy:stop()
end

return _spoon
