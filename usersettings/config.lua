Config = {
  --## ITEM AUTO ADD
  AutoAddItems = true, --## QBCore will automatically add these to the shared.lua if using an upto date version. ESX will add items to the table you configure below
  ESXItemTable = "items",
  --## JOB EVENTS
  PoliceJobs = {
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

  -- EARLY BETA DONT USE
  UsingPrompts = false,
  Prompts = {
    ['Test Position'] = {
      Distance     = 4.0,
      InteractDistance = 1.5, --# For buttons how close before you can press it
      --Models       = {"prop_traffic_03a"},
      Position     = vector4(133.03620910645,-1462.8515625,29.357049942017,236.15692138672),
      OtherPlayers = false,

      Buttons = {},

      ClickOptions     = {
        ['Knock Door'] = {
          Icon = "fa-solid fa-house",
          Text = "Knock Door",

          canInteract = function()
            if can then
              return true
            end
            return true
          end,

          action = function()
            print('Triggered')
          end,
        }
      },
    },
    ['Bin2'] = {
      Distance     = 4.0,
      InteractDistance = 1.5, --# For buttons how close before you can press it
      Models       = {"prop_rub_binbag_03b"},
      -- Position     = vector4(133.03620910645,-1462.8515625,29.357049942017,236.15692138672),
      OtherPlayers = false,

      Buttons = {},

      ClickOptions     = {
        ['Search'] = {
          Icon = "fa-solid fa-magnifying-glass",
          Text = "Search Rubbish",

          canInteract = function()
            if can then
              return true
            end
            return true
          end,

          action = function()
            print('Triggered')
          end,
        }
      },
    },
    ['Bin'] = {
      Distance     = 4.0,
      InteractDistance = 1.5, --# For buttons how close before you can press it
      Models       = {"prop_bin_02a"},
      -- Position     = vector4(133.03620910645,-1462.8515625,29.357049942017,236.15692138672),
      OtherPlayers = false,

      Buttons = {},

      ClickOptions     = {
        ['Search'] = {
          Icon = "fa-solid fa-magnifying-glass",
          Text = "Search Bin",

          canInteract = function()
            if can then
              return true
            end
            return true
          end,

          action = function()
            print('Triggered')
          end,
        }
      },
    },
    ['Pay Phone'] = {
      Distance     = 4.0,
      Offset       = vector3(0.0,0.0,1.0), --## use if you want an offset from the model or position I guess
      InteractDistance = 1.5, --# For buttons how close before you can press it
      -- Models       = {"prop_phonebox_01c"},
      Position        = vector4(7.1477069854736,-1452.6342773438,30.52773475647,115.18687438965),
      OtherPlayers = false,

      Buttons = {},

      ClickOptions     = {
        ['Call Police'] = {
          Icon = "fa-solid fa-phone",
          Text = "Use PayPhone",

          canInteract = function()
            if can then
              return true
            end
            return true
          end,

          action = function()
            print('Triggered')
          end,
        }
      },
    },
    ['All Vehicles'] = {
      Distance     = 4.0,
      InteractDistance = 1.5,
      AllPeds = false, --## Will Apply to all peds
      AllVehicles = true, --##
      -- Position     = vector4(126.35858917236,-1455.4478759766,29.294437408447,152.05372619629),
      OtherPlayers = false,

      Buttons = {
        ['Lock Door'] = {
          Key         = "B",
          KeyCode     = 29,
          Text        = "Lock Car",
          canInteract = function(entity)
            if IsEntityDead(entity) then return false; end
            local lockStatus = tonumber(GetVehicleDoorLockStatus(entity))
            print(lockStatus)
            if lockStatus ~= 0 or lockStatus ~= 1 then return false; end
            return true
          end,

          action = function(entity)
            print('Here')
            SetVehicleDoorsLocked(entity, 2)
          end,
        },
        ['Unlock Door'] = {
          Key         = "J",
          KeyCode     = 25,
          Text        = "Mug",
          canInteract = function(entity)
            if IsEntityDead(entity) then return false; end
            return true
          end,

          action = function(entity)
            print('Triggered')
          end,
        },

      },

      ClickOptions     = {},
    },
    ['All Peds'] = {
      Distance     = 4.0,
      InteractDistance = 1.5,
      AllPeds = true, --## Will Apply to all peds
      AllVehicles = false, --##
      -- Position     = vector4(126.35858917236,-1455.4478759766,29.294437408447,152.05372619629),
      OtherPlayers = false,

      Buttons = {
        ['Mug'] = {
          Key         = "B",
          KeyCode     = 29,
          Text        = "Mug",
          canInteract = function(entity)
            return true
          end,

          action = function(entity)
            print('Here')
            SetVehicleDoorsLocked(entity, 2)
          end,
        },
      },

      ClickOptions     = {
        ['Search Player'] = {
          Icon = "fa-solid fa-phone",
          Text = "Search Player",

          canInteract = function()
            return true
          end,

          action = function()
            print('Triggered')
          end,
        }
      },
    },
  },
}

getCore = function()
  return Core, Config
end

