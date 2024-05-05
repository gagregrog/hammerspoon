--- === Menudo ===
---
--- Load spoons into a menu and start them
---
--- Download: ?

local _spoon = {}
_spoon.__index = _spoon

-- Metadata
_spoon.name = "Menudo"
_spoon.version = "1.0"
_spoon.author = "Robert Reed <robert.mc.reed@gmail.com>"
_spoon.homepage = "https://github.com/Hammerspoon/Spoons"
_spoon.license = "MIT - https://opensource.org/licenses/MIT"
_spoon.config_path = hs.spoons.resourcePath("config.json")

function _spoon:read()
    _spoon.config = hs.json.read(_spoon.config_path) or {}
end

--- spoon.Menudo:start(spoons)
--- Method
--- Start the menu with the given spoons
---
--- Parameters:
---  * spoons -  list of spoon names
function _spoon:start(spoons)
    local diskIcon = hs.image.imageFromPath(hs.spoons.resourcePath("img/spoon.png"))
    _spoon.mb = hs.menubar.new(true, "menudo"):setIcon(diskIcon:setSize({w=16,h=16}))
    _spoon:read()

    local initial_menus = {}
    for _, current_spoon_name in ipairs(spoons) do
        hs.loadSpoon(current_spoon_name)
        if _spoon.config[current_spoon_name] == nil then
            _spoon.config[current_spoon_name] = {
                enabled = true
            }
        end
        
        if _spoon.config[current_spoon_name].enabled  then
            spoon[current_spoon_name]:start()
        end

        local menu_item = {
            title = current_spoon_name,
            checked = _spoon.config[current_spoon_name].enabled,
            fn = _spoon:handleMenuClick(current_spoon_name)
        }
        table.insert(initial_menus, menu_item)
    end

    _spoon.mb:setMenu(initial_menus)
end

function _spoon:handleMenuClick(clicked_spoon)
    return function()
        local menus = {}

        for current_spoon_name, current_spoon_config in pairs(_spoon.config) do
            if clicked_spoon == current_spoon_name then
                if current_spoon_config.enabled then
                    spoon[current_spoon_name]:stop()
                else
                    spoon[current_spoon_name]:start()
                end
                _spoon.config[current_spoon_name].enabled = not current_spoon_config.enabled
            end

            local menu_item = {
                title = current_spoon_name,
                checked = _spoon.config[current_spoon_name].enabled,
                fn = _spoon:handleMenuClick(current_spoon_name)
            }

            table.insert(menus, menu_item)
        end

        _spoon.mb:setMenu(menus)
        hs.json.write(_spoon.config, _spoon.config_path, true, true)
    end
end

return _spoon
