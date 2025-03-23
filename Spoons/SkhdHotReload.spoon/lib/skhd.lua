-- extended implementation shown here: https://github.com/Hammerspoon/hammerspoon/issues/2196

local SkhdHotReload = {}
SkhdHotReload.__index = SkhdHotReload

-- Logger
local log = hs.logger.new("Menudo", "debug")

-- Watch skhd config file for changes
local home = os.getenv("HOME")
local skhd_config = home .. "/.config/skhd/skhdrc"
local skhd_watcher = hs.pathwatcher.new(skhd_config, function(files)
	log.i("SHKD config updated!")
	-- second argument is required in order to load our shell environment
	hs.execute("skhd -r", true)
end)

function SkhdHotReload:start()
	skhd_watcher:start()
end

function SkhdHotReload:stop()
	skhd_watcher:start()
end

return SkhdHotReload
