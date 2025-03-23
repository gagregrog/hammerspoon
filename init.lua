-- require hs.ipc to enable hs cli
require("hs.ipc")

-- keep console output clean
hs.console.clearConsole()

hs.loadSpoon("ReloadConfiguration")

spoon.ReloadConfiguration:start()

hs.loadSpoon("Menudo")
spoon.Menudo:start({
	"AutoCopy",
	"SkhdHotReload",
	"Windex",
})
