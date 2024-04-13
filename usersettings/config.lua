Config = {
  UsingTarget         = true,     --## If you are using a target system then set this to true otherwise set to false and use my dirk-shn where possible ( not possible with every script ). 
  MenuMouseKey        = "LMENU",  --## Used to activate your mouse when close to my menu system prompts
  --## ITEM AUTO ADD
  AutoAddItems        = true,     --## QBCore will automatically add these to the shared.lua if using an upto date version. ESX will add items to the table you configure below
  ItemsDatabaseName   = "items",  --## ESX Users this will usually just be items its for autoadding items
  --## JOB EVENTS
  PoliceJobs          = {police = true, lspd = true},
  --## LANGUAGE FOR SCRIPTS
  Language            = "ENG",    --## "ENG", "ESP", "POR", "FRA", "NLD", "DAN", "SWE", "DEU", "ARA", "HIN"  --## SOME SCRIPTS MAY NOT HAVE TRANSLATIONS FOR ALL THESE LANGUAGES
  DrawDebug           = false,
  --## FRAMEWORK ACCOUNT SETTINGS
  FrameworkAccounts   = {'cash','bank'},

  --## EVENT DEBUGGER
  EventDebugger       = false,    --## Used to debug events, will save a file so you can see most commonly spammed mass events in your server (mass being events sent to every client at once)
  ------------------------------------------------------------------------------------------------------------------------------------------------------------
  UsingClassicCommand = false,    --## If you want to use the old command /target
  NewQSInventory      = false,    --## Had to add this because the name of the inventoryt is the same from v1-v2
------------------------------------------------------------------------------------------------------------------------------------------------------------
  Currency            = "$",      --## Currency symbol

  WaitForPlayerReady  = 360, --## How long before the script will give up waiting for the player to be ready (seconds) 
  NotifyPos           = "topCenter", --## Where the notification will appear on the screen, topCenter, topLeft, topRight, bottomCenter, bottomLeft, bottomRight, center
  --[[
    DO NOT RENAME OR CHANGE ANYTHING BELOW UNLESS YOU HAVE RENAMED A RESOURCE THAT IS LISTED BELOW, REFER TO THE DOCS FOR MORE INFO 
  ]]
  AlternativeResourceNames = { --## Replace false with the alternative name you have used for that resource if you are renaming resources.
    Inventory = {
      ['qb-inventory'] = false,
      ['ps-inventory'] = false,
      ['ox_inventory'] = false,
      ['mf-inventory'] = false,
      ['lj-inventory'] = false,
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
      ['qb-weathersync'] = false,
    },
    JailSystem     = {
      ['esx_jail']  = false,
      ['qb-prison'] = false,
      ['rcore_prison'] = false,
    },
    ProgressBar    = {
      ['progressbar'] = false,
      ['ox_lib']      = false,
    },
    Framework      = {
      ['es_extended'] = false,
      ['qb-core']     = false,
      ['vrp']         = false,
    },
    KeySystem      = {
      ['qb-vehiclekeys'] = false,
      ['qs-vehiclekeys'] = false,
      ['okokGarage'] = false,
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
    FuelSystem      = {
      ['ox_fuel']      = false,
      ['ps-fuel']      = false,
      ['cdn_fuel']     = false,
      ['Renewed-Fuel'] = false,
      ['LegacyFuel']   = false,
    }
  },

  VehicleClassCapacities = {
    ["Compacts"] = 500,
    ["Sedans"] = 500,
    ["SUVs"] = 500,
    ["Coupes"] = 500,
    ["Muscle"] = 500,
    ["Sports Classics"] = 500,
    ["Sports"] = 500,
    ["Super"] = 500,
    ["Motorcycles"] = 500,
    ["Off-road"] = 500,
    ["Industrial"] = 500,
    ["Utility"] = 500,
    ["Vans"] = 500,
    ["Cycles"] = 500,
    ["Boats"] = 500,
    ["Helicopters"] = 500,
    ["Planes"] = 500,
    ["Service"] = 500,
    ["Emergency"] = 500,
    ["Military"] = 500,
    ["Commercial"] = 500,
    ["Trains"] = 500,
  },
}

