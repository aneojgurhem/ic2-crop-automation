local shell = require('shell')
local scripts = {
    'action.lua',
    'database.lua',
    'gps.lua',
    'posUtil.lua',
    'scanner.lua',
    'signal.lua',
    'autoStat.lua',
    'autoTier.lua',
    'autoSpread.lua',
    'config.lua',
    'install.lua',
    'uninstall.lua'
}

-- UNINSTALL
for i=1, #scripts do
    shell.execute(string.format('rm %s', scripts[i]))
    print(string.format('Uninstalled %s', scripts[i]))
end