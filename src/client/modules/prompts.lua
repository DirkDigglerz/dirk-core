local currentPrompts = {}
local Prompts = {}

Config.UsingPrompts = false
Config.Prompts = {
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
}

Init = function()
  while not Core.Player.Ready() do Wait(5000); end
  for k,v in pairs(Config.Prompts) do
    Prompts[k] = v
  end
  Update()
end

modelMatch = function(models, ent)
  local entModel = GetEntityModel(ent)
  for k,v in pairs(models) do
    if tonumber(entModel) == tonumber(GetHashKey(v)) then
      return true
    end
  end
  return false
end

Update = function()
  while true do
    local wait_time = 1000
    local ply = PlayerPedId()
    local pos = GetEntityCoords(ply)

    local entPool = Core.Game.GetEntityPool()



    for id,data in pairs(Prompts) do
      local promptPos = false
      local promptEnt = false
      if data.Position then
        promptPos = data.Position
      elseif data.Models or data.AllPeds or data.AllVehicles or data.OtherPlayers then
        for _,ent in pairs(entPool) do
          local entCoords =  GetEntityCoords(ent)

          if #(entCoords.xyz - pos) <= data.Distance then
            if ent ~= ply then
              if data.Models then
                if modelMatch(data.Models, ent) then
                  promptEnt = ent
                  promptPos = entCoords
                end
              else
                if data.AllPeds then
                  if IsEntityAPed(ent) and (data.OtherPlayers or not IsPedAPlayer(ent)) then
                    promptEnt = ent
                    promptPos = entCoords
                  end
                elseif data.Entity then
                  if NetworkGetEntityFromNetworkId(ent) == data.Entity or data.Entity == ent then
                    promptEnt = ent
                    promptPos = entCoords
                  end
                elseif data.AllVehicles then
                  if IsEntityAVehicle(ent) then
                    promptEnt = ent
                    promptPos = entCoords
                  end
                elseif data.OtherPlayers then
                  if IsPedAPlayer(ent) then
                    promptEnt = ent
                    promptPos = entCoords
                  end
                end
              end
            end
          end
        end
      end

      if promptEnt and not IsEntityOnScreen(promptEnt) then promptPos = false; end

      if promptPos and #(promptPos.xyz - pos) <= data.Distance then
        wait_time = 0
        DisplayPrompt(id, promptPos, data, promptEnt)
        if not data.InteractDistance or #(promptPos.xyz - pos) <= data.InteractDistance then
          for k,v in pairs(data.Buttons) do
            if IsControlJustPressed(0,v.KeyCode) then
              v.action(promptEnt)
            end
          end
        end
      else

        ClosePrompt(id)
      end

    end
    Wait(wait_time)
  end
end

RegisterNUICallback('optionChosen', function(e)
  if Prompts[e.id] then
    Prompts[e.id][e.type][e.typeid].action(e.ent)
  end
end)

DisplayPrompt = function(id, pos, data, ent)
  if not currentPrompts[id] then
    currentPrompts[id] = {
      Ent          = ent,
      Buttons      = {},
      ClickOptions = {},
    }
  end
  local promptChange = false
  for k,v in pairs(data.ClickOptions) do
    if not v.canInteract(ent) then
      if currentPrompts[id].ClickOptions[k] then
        currentPrompts[id].ClickOptions[k] = nil
        promptChange = true
      end
    else
      if not currentPrompts[id].ClickOptions[k] then
        currentPrompts[id].ClickOptions[k] = {
          text = v.Text,
          icon = v.Icon,
        }
        promptChange = true
      end
    end
  end

  for k,v in pairs(data.Buttons) do
    if not v.canInteract(ent) then
      if currentPrompts[id].Buttons[k] then
        currentPrompts[id].Buttons[k] = nil
        promptChange = true
      end
    else
      if not currentPrompts[id].Buttons[k] then
        currentPrompts[id].Buttons[k] = {
          text = v.Text,
          button = v.Key,
        }
        promptChange = true
      end
    end
  end
  if Prompts[id].Offset then pos = vector3(pos.x, pos.y,pos.z) + Prompts[id].Offset; end
  local r,x,y = GetHudScreenPositionFromWorldPosition(pos.x,pos.y,pos.z)
  local pX, pY = GetAsPercent(x,y)
  SendNUIMessage({
    type = "displayPrompt",
    id = id,
    options = currentPrompts[id],
    promptChange = promptChange,
    x = pX,
    y = pY,
  })
end

ClosePrompt = function(id)
  if not currentPrompts[id] then return false; end
  currentPrompts[id] = nil
  SendNUIMessage({
    type = "closePrompt",
    id = id,
  })
end



RegisterNUICallback('LoseFocus', function()
  SetNuiFocus(false,false)
  Focused = false
end)


RegisterCommand('nuifocus', function()
  if not Focused then
    Focused = true
    SetNuiFocus(true,true)
    SendNUIMessage({
      type = "promptFocus",
    })
  end
end, false)

RegisterKeyMapping('nuifocus', 'DIRK TARGET', 'keyboard', 'o')

GetAsPercent = function(n1, n2)
  return n1 * 100, n2 * 100
end

if Config.UsingPrompts then
  Citizen.CreateThread(Init)
end