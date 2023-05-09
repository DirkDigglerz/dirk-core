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
}

getCore = function()
  return Core, Config
end

