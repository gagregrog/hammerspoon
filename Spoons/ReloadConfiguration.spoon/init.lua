--- === ReloadConfiguration ===
---
--- Adds a hotkey to reload the hammerspoon configuration, and a pathwatcher to automatically reload on changes.
---
--- Download: [https://github.com/Hammerspoon/Spoons/raw/master/Spoons/ReloadConfiguration.spoon.zip](https://github.com/Hammerspoon/Spoons/raw/master/Spoons/ReloadConfiguration.spoon.zip)

local obj = {}
obj.__index = obj

-- Metadata
obj.name = "ReloadConfiguration"
obj.version = "1.0"
obj.author = "Jon Lorusso <jonlorusso@gmail.com>"
obj.homepage = "https://github.com/Hammerspoon/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"

--- ReloadConfiguration:bindHotkeys(mapping)
--- Method
--- Binds hotkeys for ReloadConfiguration
---
--- Parameters:
---  * mapping - A table containing hotkey modifier/key details for the following items:
---   * reloadConfiguration - This will cause the configuration to be reloaded
function obj:bindHotkeys(mapping)
   local def = { reloadConfiguration = hs.fnutils.partial(hs.reload, self) }
   hs.spoons.bindHotkeysToSpec(def, mapping)
end

function obj:handleReload(paths)
    hs.fnutils.each(paths, function(path)
        -- ignore these weird sync files
        local should_skip = path:match(".dat.nosyncaefa")
        hs.fnutils.each(self.ignore_paths, function(reg)
            should_skip = should_skip or path:match(reg)
        end)

        if not should_skip then
            hs.reload()
        end
    end)
end

--- ReloadConfiguration:start()
--- Method
--- Start ReloadConfiguration
---
--- Parameters:
---  * config - associative array with list of ignore_paths and watch_paths, both optional
function obj:start(config)
    config = config or {}
    self.ignore_paths = config.ignore_paths or {}
    self.watch_paths = config.watch_paths or { hs.configdir }
    
    self.watchers = {}
    for _,dir in pairs(self.watch_paths) do
        self.watchers[dir] = hs.pathwatcher.new(dir, function(paths) self:handleReload(paths) end):start()
    end
    return self
end

return obj
