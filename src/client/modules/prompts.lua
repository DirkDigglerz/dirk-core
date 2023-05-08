local currentPrompts = {}
local Prompts = {}

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