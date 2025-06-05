-- require hs.ipc to enable hs cli
require("hs.ipc")

-- keep console output clean
hs.console.clearConsole()

hs.loadSpoon("ReloadConfiguration")

spoon.ReloadConfiguration:start()

hs.loadSpoon("Menudo")
spoon.Menudo:start({
	{
		name = "AutoCopy",
		config = {
			-- NOTE: To find the bundle identifier for an application:
			-- osascript -e 'id of app "Application Name"'
			skipIDs = {
				"com.apple.QuickTimePlayerX",
				"cc.ffitch.shottr",
				"app.tuple.app",
				"com.autodesk.fusion360",
			},
		},
	},
	"SkhdHotReload",
	"Windex",
})
