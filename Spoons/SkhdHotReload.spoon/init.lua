-- extended implementation shown here: https://github.com/Hammerspoon/hammerspoon/issues/2196
SkhdHotReload = dofile(hs.spoons.resourcePath("lib/skhd.lua"))

local _spoon = {}
_spoon.__index = _spoon

_spoon.name = "SkhdHotReload"
_spoon.version = "1.0"
_spoon.author = "Robert Reed"
_spoon.homepage = "https://github.com/Hammerspoon/Spoons"
_spoon.license = "MIT - https://opensource.org/licenses/MIT"

--- spoon.SkhdHotReload:start()
--- Method
--- Start watching SKHD config path for changes
--- Reload skhd on change
---
--- Parameters:
---  * None
function _spoon:start()
	SkhdHotReload:start()
end

--- spoon.SkhdHotReload:stop()
--- Method
--- stop watching for file changes
---
--- Parameters:
---  * None
function _spoon:stop()
	SkhdHotReload:stop()
end

return _spoon
