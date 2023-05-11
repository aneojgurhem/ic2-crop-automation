local shell = require("shell")
local scripts = {
    "action.lua",
    "database.lua",
    "gps.lua",
    "posUtil.lua",
    "scanner.lua",
    "signal.lua",
    "autoStat.lua",
    "autoTier.lua",
    "autoSpread.lua",
    "config.lua",
    "install.lua",
    "uninstall.lua"
}

for i=1, #scripts do
    shell.execute(string.format("rm %s", scripts[i]))
    print("Successfully Uninstalled %s", scripts[i])
end