Core.Game = {
  LoadModel = function(m)
    local hash = GetHashKey(m)
    while not HasModelLoaded(hash) do RequestModel(hash) Wait(0); end
    return true
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

  PlotPoints = function()
    local points = {}
    while true do
      local wait_time = 0
      local hit, endCoords, entityHit = Core.UI.ScreenToWorld()
      if (endCoords ~= vector3(0,0,0) and entityHit ~= ply) then
        DrawSphere(endCoords.x,endCoords.y,endCoords.z, 0.4, 255,0,0, 0.7)
        Core.UI.ShowHelpNotification("Press ~INPUT_CELLPHONE_CAMERA_GRID~ to add a point\nPress ~INPUT_CELLPHONE_CANCEL~ to delete last coordinate\nPress ~INPUT_CELLPHONE_CAMERA_DOF~ to finish")
        if IsControlJustPressed(0,183) then
          table.insert(points, endCoords)
        elseif IsControlJustPressed(0,177) then
          points[#points] = nil
        elseif IsControlJustPressed(0,185) then
          return points
        end
      end
      Wait(wait_time)
    end
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
    local pool, ply, coords, closestPlayer, closestDistance = Core.Game.GetEntityPool({'CPed'}), PlayerPedId(), GetEntityCoords(ply), 99999999, 99999999
    for k,v in pairs(pool) do
      if IsPedAPlayer(v) then 
        local pedCoords = GetEntityCoords(v)
        local distance  = #(pedCoords - coords)
        if distance <= closestDistance then 
          closestPlayer = v
          closestDistance = distance
        end 
      end
    end
    return closestPlayer, closestDistance
  end, 

  GetClosestPed = function(pos, ignoreMe)
    local pool, ply, coords, closestPed, closestDistance = Core.Game.GetEntityPool({'CPed'}), PlayerPedId(), GetEntityCoords(ply), 99999999, 99999999
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
    local pool, ply, coords, closestObject, closestDistance = Core.Game.GetEntityPool({'CObject'}), PlayerPedId(), GetEntityCoords(ply), 99999999, 99999999
    for k,v in pairs(pool) do
      local pedCoords = GetEntityCoords(v)
      local distance  = #(pedCoords - coords)
      if distance <= rad and distance <= closestDistance then 
        if GetEntityModel(v) == tonumber(model) then
          closestObject = v
          closestDistance = distance
        end
      end 
    end
    return closestObject, closestDistance
  end,

  GetClosestVehicle = function(cs)
    local pool, ply, coords, closestVehicle, closestDistance = Core.Game.GetEntityPool({'CVehicle'}), PlayerPedId(), GetEntityCoords(ply), 99999999, 99999999
    for k,v in pairs(pool) do
      local pedCoords = GetEntityCoords(v)
      local distance  = #(pedCoords - coords)
      if distance <= closestDistance then 
        closestVehicle = v
        closestDistance = distance
      end 
    end
    return closestVehicle, closestDistance
  end
}


