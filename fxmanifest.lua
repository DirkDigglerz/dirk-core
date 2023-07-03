fx_version 'adamant'
games { 'rdr3', 'gta5' }
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
lua54 'yes'
author 'DirkScripts'
description 'Dirk-Script'
version '1.0.0'

client_script {
  'usersettings/config.lua',
  'usersettings/labels.lua',
  'usersettings/init.lua',
  'src/client/core.lua',
  'src/client/modules/*.lua',
  'usersettings/shared.lua',
}


server_script {
  -- '@mysql-async/lib/MySQL.lua', -- Uncomment if not using oxmysql
  '@oxmysql/lib/MySQL.lua', -- Comment out if not using oxmysql
  'usersettings/config.lua',
  'usersettings/labels.lua',
  'usersettings/init.lua',
  'src/server/core.lua',
  'src/server/modules/*.lua',
  'usersettings/shared.lua',
}

---## IF YOU ARE NOT USING OX_LIB YOU NEED TO COMMENT THE BELOW OUT OR NONE OF YOUR DIRKSCRIPTS WILL WORK ##---
shared_script '@ox_lib/init.lua' -- Unomment this out if using ox_lib

dependencies{
  'oxmysql', -- Comment out if not using oxmysql
  'ox_lib' -- Comment out if not using ox_lib
}

exports{
  'getCore',
}



server_exports{
  'getCore',
}

ui_page 'src/nui/index.html'

files{
  'src/nui/index.html',
  -- MAIN
  'src/nui/main/*.*',
  'src/nui/prompts/*.*',
  'src/nui/keycode/*.*',

}

