--- === Menudo ===
---
--- Load spoons into a menu and start them
---
--- Download: ?

local _spoon = {}
_spoon.__index = _spoon

-- Logger
local log = hs.logger.new("Menudo", "debug")

-- Deep copy function to ensure we don't share references
local function deepcopy(orig)
	local orig_type = type(orig)
	local copy
	if orig_type == "table" then
		copy = {}
		for orig_key, orig_value in pairs(orig) do
			copy[deepcopy(orig_key)] = deepcopy(orig_value)
		end
	else
		copy = orig
	end
	return copy
end

-- Metadata
_spoon.name = "Menudo"
_spoon.version = "1.0"
_spoon.author = "Robert Reed <robert.mc.reed@gmail.com>"
_spoon.homepage = "https://github.com/Hammerspoon/Spoons"
_spoon.license = "MIT - https://opensource.org/licenses/MIT"
_spoon.config_path = os.getenv("HOME") .. "/.config/menudo.json"

function _spoon:read()
	local success, result = pcall(function()
		return hs.json.read(_spoon.config_path)
	end)

	if not success or not result then
		_spoon.config = {}
		return
	end

	_spoon.config = result
end

--- spoon.Menudo:start(spoons)
--- Method
--- Start the menu with the given spoons
---
--- Parameters:
---  * spoons -  list of spoon names
function _spoon:start(spoons)
	_spoon.spoons = spoons
	local diskIcon = hs.image.imageFromPath(hs.spoons.resourcePath("img/spoon.png"))
	_spoon.mb = hs.menubar.new(true, "menudo"):setIcon(diskIcon:setSize({ w = 16, h = 16 }))
	_spoon:read()

	for _, spoon_name in ipairs(spoons) do
		if _spoon.config[spoon_name] == nil then
			log.i("Found new spoon: " .. spoon_name)
			_spoon.config[spoon_name] = {
				enabled = true,
			}
		end

		if _spoon.config[spoon_name].enabled then
			hs.loadSpoon(spoon_name)
			spoon[spoon_name]:start()
		end
	end

	_spoon.mb:setMenu(_spoon:createMenuItems())
end

function _spoon:createMenuItems()
	local menus = {}
	for _, spoon_name in ipairs(_spoon.spoons) do
		local menu_item = {
			title = spoon_name,
			checked = _spoon.config[spoon_name].enabled,
			fn = function()
				log.d("Handling click for spoon:", spoon_name)

				-- Make a deep copy of the current config
				local config_copy = deepcopy(_spoon.config)

				-- Update only this spoon's state in the copy
				config_copy[spoon_name].enabled = not config_copy[spoon_name].enabled

				-- Replace the entire config with our copy
				_spoon.config = config_copy

				-- Toggle spoon based on updated state
				if _spoon.config[spoon_name].enabled then
					-- load the spoon if it hasn't been loaded yet
					if not spoon[spoon_name] then
						hs.loadSpoon(spoon_name)
					end

					log.d("Enabling spoon: " .. spoon_name)
					spoon[spoon_name]:start()
				else
					log.d("Disabling spoon: " .. spoon_name)
					spoon[spoon_name]:stop()
				end

				-- Update menu with new state
				_spoon.mb:setMenu(_spoon:createMenuItems())

				-- persist new state
				hs.json.write(_spoon.config, _spoon.config_path, true, true)
			end,
		}
		table.insert(menus, menu_item)
	end
	return menus
end

return _spoon
