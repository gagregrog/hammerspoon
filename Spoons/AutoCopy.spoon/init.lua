-- extended implementation shown here: https://github.com/Hammerspoon/hammerspoon/issues/2196
AutoCopy = dofile(hs.spoons.resourcePath("lib/autoCopy.lua"))

local _spoon = {}
_spoon.__index = _spoon

_spoon.name = "AutoCopy"
_spoon.version = "1.0"
_spoon.author = "Robert Reed"
_spoon.homepage = "https://github.com/Hammerspoon/Spoons"
_spoon.license = "MIT - https://opensource.org/licenses/MIT"

--- spoon.AutoCopy:start()
--- Method
--- Start AutoCopy
---
--- Parameters:
---  * None
function _spoon:start()
  AutoCopy:start()
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
