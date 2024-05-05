-- import the Windex class
Windex = dofile(hs.spoons.resourcePath("lib/windex.lua"))


--- === Windex ===
---
--- Add hotkeys for window management.
---
--- Download: ?

local _spoon = {}
_spoon.__index = _spoon

-- Metadata
_spoon.name = "Windex"
_spoon.version = "1.0"
_spoon.author = "Robert Reed <robert.mc.reed@gmail.com>"
_spoon.homepage = "https://github.com/Hammerspoon/Spoons"
_spoon.license = "MIT - https://opensource.org/licenses/MIT"

_spoon.defult_keybinds = {
    up = {{"cmd", "alt", "ctrl"}, "Up"},
    down = {{"cmd", "alt", "ctrl"}, "Down"},
    center = {{"cmd", "alt", "ctrl"}, "Return"},

    right = {{"cmd", "alt", "ctrl"}, "Right"},
    upper_right = {{"cmd", "alt", "ctrl"}, "F15"},
    lower_right = {{"cmd", "alt", "ctrl"}, "F16"},
    
    left = {{"cmd", "alt", "ctrl"}, "Left"},
    upper_left = {{"cmd", "alt", "ctrl"}, "F17"},
    lower_left = {{"cmd", "alt", "ctrl"}, "F18"},
    
    up_reverse = {{"cmd", "alt", "ctrl", "shift"}, "Up"},
    down_reverse = {{"cmd", "alt", "ctrl", "shift"}, "Down"},
    center_reverse = {{"cmd", "alt", "ctrl", "shift"}, "Return"},

    right_reverse = {{"cmd", "alt", "ctrl", "shift"}, "Right"},
    upper_right_reverse = {{"cmd", "alt", "ctrl", "shift"}, "F15"},
    lower_right_reverse = {{"cmd", "alt", "ctrl", "shift"}, "F16"},
    
    left_reverse = {{"cmd", "alt", "ctrl", "shift"}, "Left"},
    upper_left_reverse = {{"cmd", "alt", "ctrl", "shift"}, "F17"},
    lower_left_reverse = {{"cmd", "alt", "ctrl", "shift"}, "F18"},
}

--- Windex:bindHotkeys(mapping)
--- Method
--- Binds hotkeys for Windex
---
--- Parameters:
---  * mapping - A table containing hotkey modifier/key details for the following items:
-- spoon.Windex:bindHotkeys({
--   right = {{"cmd", "alt", "ctrl"}, "Right"},
--   left = {{"cmd", "alt", "ctrl"}, "Left"},
--   center = {{"cmd", "alt", "ctrl", "shift"}, "Return"},
-- })

function _spoon:bindHotkeys(mapping)
    local def = {
        up = Windex:up(),
        down = Windex:down(),
        center = Windex:center(),

        right = Windex:right(),
        upper_right = Windex:upper_right(),
        lower_right = Windex:lower_right(),
        
        left = Windex:left(),
        upper_left = Windex:upper_left(),
        lower_left = Windex:lower_left(),
        
        up_reverse = Windex:up(true),
        down_reverse = Windex:down(true),
        center_reverse = Windex:center(true),

        right_reverse = Windex:right(true),
        upper_right_reverse = Windex:upper_right(true),
        lower_right_reverse = Windex:lower_right(true),
        
        left_reverse = Windex:left(true),
        upper_left_reverse = Windex:upper_left(true),
        lower_left_reverse = Windex:lower_left(true),
    }

    _spoon.keybinds = {}
    _spoon.keybind_map = mapping
    for direction, current_mapping in pairs(mapping) do
        if def[direction] then
            table.insert(
                _spoon.keybinds,
                hs.hotkey.bind(
                    current_mapping[1],
                    current_mapping[2],
                    def[direction]
                )
            )
            else
                print('[Windex] Unknown command: ' .. direction)
        end
    end
    -- not using bindHotKeysToSpec so the mapping can be unbound
    -- hs.spoons.bindHotkeysToSpec(def, mapping)
end

--- spoon.Windex:stop()
--- Method
--- Stop Windex and remove all keybinds
---
--- Parameters:
---  * None
function _spoon:stop()
    if not _spoon.keybinds then return end

    for _, kb in ipairs(_spoon.keybinds) do
        kb:delete()
    end

    _spoon.keybinds = nil
end

--- spoon.Windex:start()
--- Method
--- Internal: toggle windex on or off
---
--- Parameters:
---  * None
function _spoon:start(user_keybinds)
    _spoon:bindHotkeys(user_keybinds or _spoon.keybind_map or _spoon.defult_keybinds)
end

return _spoon
