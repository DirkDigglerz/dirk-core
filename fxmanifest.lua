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
  'src/client/core.lua',
  'src/client/modules/*.lua',
}


server_script {
  -- '@mysql-async/lib/MySQL.lua', -- Uncomment if not using oxmysql
  '@oxmysql/lib/MySQL.lua', -- Comment out if not using oxmysql
  'usersettings/config.lua',
  'usersettings/labels.lua',
  'src/server/core.lua',
  'src/server/modules/*.lua',
}

-- Uncomment if your script has UI. If not delete the folder upon release

dependencies{
  'oxmysql',
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
  'src/nui/inventory/*.*',
  'src/nui/keycode/*.*',
  -- INventory
  'src/nui/inventory/*.png',  
}