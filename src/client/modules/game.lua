Core.Game = {
  LoadModel = function(m)
    local hash = GetHashKey(m)
    while not HasModelLoaded(hash) do RequestModel(hash) Wait(0); end
    return hash
  end,

  SyncTime = function(s)
    if Config.TimeSystem == "cd_easytime" then
      TriggerEvent('cd_easytime:PauseSync', s)
    elseif Config.TimeSystem == "vSync" then
      if s then TriggerServerEvent('vSync:requestSync'); end
    elseif Config.TimeSystem == "qb-weathersync" then
      if s then TriggerEvent("qb-weathersync:client:EnableSync") return true; end
      if not s then TriggerEvent("qb-weathersync:client:DisableSync") return true; end
    end
  end,

  AddBlip = function(pos, data)
    local blip = AddBlipForCoord(pos.x,pos.y,pos.z)
    SetBlipSprite (blip, data.Sprite)
    SetBlipDisplay(blip, data.Display)
    SetBlipScale  (blip, data.Scale)
    SetBlipColour (blip, data.Color)
    SetBlipAsShortRange(blip, data.ShortRange)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(data.Text)
    EndTextCommandSetBlipName(blip)

    if data.Route then
      SetBlipRoute(blip,true)
    end
    return blip
  end,

  RemoveBlip = function(id)
    RemoveBlip(id)
  end,

  EntityViewer = function()
    
  end,

  ChooseNearbyPlayer = function()
    local pedPool = Core.Game.GetEntityPool({'CPed'})
    local nearPlayers = {}
    local ply = PlayerPedId()
    local pos = GetEntityCoords(ply)
    local currentSelect, index = nil, nil
    for k,v in pairs(pedPool) do 
      if IsPedAPlayer(v) and v ~= ply then 
        local pedCoords = GetEntityCoords(v)
        local distance  = #(pedCoords - pos)
        if distance <= 20.0 then 
          table.insert(nearPlayers, v)     
        end 
      end
    end

    for k,v in pairs(nearPlayers) do 
      if k then 
        index = k 
        currentSelect = nearPlayers[k]
        break
      end
    end

    while true do
      local pedCoords = GetEntityCoords(currentSelect)
      DrawMarker(0, pedCoords.x, pedCoords.y, pedCoords.z + 1.4, 0, 0, 0, 0, 0, 0, 0.5, 0.5, 0.5, 0, 255, 0, 100, 0, 0, 0, 0)
      Core.UI.AdvancedHelpNotif("choosePlayer", {
        {
          label = "Next Player",
          key   = "->",
        },
        {
          label = "Previous player",
          key   = "<-",
        },
        {
          label = "Select Player",
          key   = "g",
        },
        {
          label = "Cancel",
          key   = "c",
        },
      })
      if IsControlJustPressed(0,175) then
        if index + 1 > #nearPlayers then
          index = 1
        else
          index = index + 1
        end
        currentSelect = nearPlayers[index]

      elseif IsControlJustPressed(0,174) then
        if index - 1 <= 0 then
          index = #nearPlayers
        else
          index = index - 1
        end
        currentSelect = nearPlayers[index]
      elseif IsControlJustPressed(0,47) then
        if IsPedAPlayer(currentSelect) then
          return GetPlayerServerId(NetworkGetPlayerIndexFromPed(currentSelect))
        else
          Core.UI.Notify("This is not a player")
        end
      elseif IsControlJustPressed(0,79) then
        return nil
      end
      Wait(0)
    end
  end,

  GetEntityPool = function(pools)
    local ret = {}
    if not pools then pools = {'CPed', 'CObject', 'CVehicle'}; end
    for _,pool in pairs(pools) do
      local retPool = GetGamePool(pool)
      for k,v in pairs(retPool) do
        table.insert(ret, v)
      end
    end
    return ret
  end,

  GetClosestPlayer = function(ignoreMe)
    if Config.Framework == "qb-core" then
      local closestPlayer, closestDistance = QBCore.Functions.GetClosestPlayer(ignoreMe)
      return closestPlayer, closestDistance
    elseif Config.Framework == "es_extended" then
      local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer(ignoreMe)
      return closestPlayer, closestDistance
    end
    return print('FRAMEWORK NOT SUPPORTED')
  end, 

  GetClosestPed = function(pos, ignoreMe)
    local pool, coords, closestPed, closestDistance = Core.Game.GetEntityPool({'CPed'}), GetEntityCoords(PlayerPedId()), 99999999, 99999999
    for k,v in pairs(pool) do
      local pedCoords = GetEntityCoords(v)
      local distance  = #(pedCoords - coords)
      if distance <= closestDistance then 
        closestPed = v
        closestDistance = distance
      end 
    end
    return closestPed, closestDistance
  end,

  GetClosestObject = function(model,rad)
    local pool, coords, closestObject, closestDistance = Core.Game.GetEntityPool({'CObject'}), GetEntityCoords(PlayerPedId()), 99999999, 99999999
    for k,v in pairs(pool) do
      local pedCoords = GetEntityCoords(v)
      local distance  = #(pedCoords - coords)
      if (rad and distance <= rad) or not rad and distance <= closestDistance then 
        if GetEntityModel(v) == tonumber(model) or not model then
          closestObject = v
          closestDistance = distance
        end
      end 
    end
    return closestObject, closestDistance
  end,

  GetClosestVehicle = function(cs)
    local pool, coords, closestVehicle, closestDistance = Core.Game.GetEntityPool({'CVehicle'}), GetEntityCoords(PlayerPedId()), 99999999, 99999999
    for k,v in pairs(pool) do
      local vehCoords = GetEntityCoords(v)
      local distance  = #(vehCoords - coords)
      if distance <= closestDistance then 
        
        closestVehicle = v
        closestDistance = distance
      end 
    end
    return closestVehicle, closestDistance
  end,
  currentCamera = false,
  oldPos = false,
  EnterCamera = function(data, dontHidePlayer)
    local ply = PlayerPedId()
    DoScreenFadeOut(1000)
    Wait(1000)
  

    if not dontHidePlayer then 
      Core.Game.oldPos = GetEntityCoords(ply)
      SetEntityLocallyInvisible(ply)
      NetworkSetEntityInvisibleToNetwork(ply, true)
      SetEntityInvincible(ply, true)
      FreezeEntityPosition(ply, true)
      SetEntityCoords(ply, Core.Game.oldPos.x, Core.Game.oldPos.y, Core.Game.oldPos.z - 25.0)
    end
    Wait(500)
  
    Core.Game.currentCamera = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    local camCoords = data.Pos
    local camRot = data.Rot
    SetCamCoord(Core.Game.currentCamera, camCoords.x, camCoords.y, camCoords.z)
    SetCamRot(Core.Game.currentCamera, camRot.x, camRot.y, camRot.z, 2)
    SetCamActive(Core.Game.currentCamera, true)
    RenderScriptCams(true, false, 1, true, true)
    DoScreenFadeIn(1000)
    Wait(1000)
    return true
  end,
  
  ExitCamera = function()
    if not Core.Game.currentCamera then return; end
    DoScreenFadeOut(1000)
    Wait(1000)
    local ply = PlayerPedId()
    if Core.Game.oldPos then 
      SetEntityCoords(ply, Core.Game.oldPos.x, Core.Game.oldPos.y, Core.Game.oldPos.z - 1.0)
      NetworkSetEntityInvisibleToNetwork(ply, false)
      SetEntityLocallyVisible(ply)
      SetEntityInvincible(ply, false)
      FreezeEntityPosition(ply, false)
    end

    DestroyCam(Core.Game.currentCamera)
    RenderScriptCams(false, false, 1, true, true)
    Core.Game.currentCamera = false
  
  
    DoScreenFadeIn(1000)
    Wait(1000)
  end
  
}
local inVehicle = false
CreateThread(function()
  while true do 
    local wait_time = 1000
    local playerPed = PlayerPedId()
    local playerVeh = GetVehiclePedIsIn(playerPed, false)
    if veh and veh ~= 0 and inVehicle == false then 
      inVehicle = true
      TriggerEvent("Dirk-Core:EnterVehicle", veh)
    end 
    if veh == 0 and inVehicle == true then 
      inVehicle = false; 
      TriggerEvent("Dirk-Core:LeaveVehicle", veh)
    end
    Wait(wait_time)
  end
end)

RegisterCommand("Dirk-Core:CameraPos", function()
  local cam = GetRenderingCam()
  local pos = GetCamCoord(cam)
  local rot = GetCamRot(cam, 2)
  local stringToCopy = string.format("CamPos = vector3(%s,%s,%s),\nCamRot = vector3(%s,%s,%s)", pos.x, pos.y,pos.z, rot.x,rot.y,rot.z)
  Core.UI.CopyToClipboard(stringToCopy)
end)