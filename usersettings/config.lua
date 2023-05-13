Config = {
  UsingTarget = true, --## If you are using a target system then set this to true otherwise set to false and use my dirk-shn where possible. 
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
  DrawDebug    = false,
  ------------------------------------------------------------------------------------------------------------------------------------------------------------
  UsingClassicCommand = false, --## If you want to use the old command /target

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

  AlternativeResourceNames = { --## Replace false with the alternative name you have used for that resource if you are renaming resources.
    Inventory = {
      ['qb-inventory'] = false,
      ['lj-inventory'] = false,
      ['ox_inventory'] = false,
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

