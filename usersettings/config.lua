Config = {
  --## ITEM AUTO ADD
  AutoAddItems = true, --## QBCore will automatically add these to the shared.lua if using an upto date version. ESX will add items to the table you configure below
  ESXItemTable = "items",
  --## JOB EVENTS
  PoliceJobs = { --## This will determine whether someone is a cop or not across all my scripts will be used for notifications etc.
    police = true,
    --lspd   = true,
  },
  --## LANGUAGE FOR SCRIPTS
  Language    = "ENG", --## "ENG"
  --## INVENTORY SETTINGS
  ItemsDatabaseName = "items", --## ESX Users this will usually just be items its for autoadding items
  StashSystem       = "default", --## If default then will use ox,qs,mf and qb-core inventories. if "dirk" then will use my stash system (ESX Default Inv will need to use mine)
  --## DEBUG FOR TARGET ZONES
  DrawDebug    = true,
  --## PROGRESS BAR OPTIONS
  ProgressBar = "OX", --## "OX" or "QB" -- Add your own in src/client/modules/ui.lua at the bottom you will find the progress bar function
  ------------------------------------------------------------------------------------------------------------------------------------------------------------
  UsingClassicCommand = false, --## If you want to use the old command /target

  AlternativeResourceNames = {
    Inventory = {
      ['qb-inventory'] = 'johboy-inventory',
      ['lj-inventory'] = false,
      ['ox_inventory'] = 'johboy-inventory',
      ['mf-inventory'] = false,
      ['qs-inventory'] = false,
    },
    TargetSystem   = {
      ['qtarget']   = false,
      ['qb-target'] = false,
      ['ox_target'] = false,
    },
    TimeSystem     = {
      ['vSync'] = false,
      ['cd_easytime']    = false,
      ['qb-weathersync'] = 'johnboy_weather',
    },
    JailSystem     = {
      ['esx_jail']  = false,
      ['qb-prison'] = false,
    },
    ProgressBar    = {
      ['progressbar'] = false,
      ['ox_lib']      = false,
    },
    Framework      = {
      ['es_extended'] = false,
      ['qb-core']     = false,
    },
    KeySystem      = {
      ['qb-vehiclekeys'] = false,
      ['cd_garage']      = false,
    },
    DispatchSystem = {
      ['ps-dispatch'] = false,
      ['cd_dispatch'] = false,
    },
    PhoneSystem    = {
      ['qs-smartphone'] = false,
      ['gks_phone']     = false,
      ['lb-phone']      = false,
      ['nwpd']          = false,
      ['qb-phone']      = false,
    },
  }
}

getCore = function()
  return Core, Config
end

