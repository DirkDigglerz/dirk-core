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
    print('Short Range', data.ShortRange)
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

  ChooseNearbyPlayer = function()
    Core.UI.Notify("Look at the player you wish to select")
    while true do
      local ply = PlayerPedId()
      local pos = GetEntityCoords(ply)
      local pool = Core.Game.GetEntityPool({'CPed'})
      local nearby = {}
      local coords = GetEntityCoords(v)
      local hit, endCoords, entityHit = Core.UI.ScreenToWorld()

      if (endCoords ~= vector3(0,0,0) and entityHit ~= ply) then
        if entityHit == v then
          Core.UI.ShowHelpNotification("Press ~INPUT_THROW_GRENADE~ to select this player")
          if IsControlJustPressed(0,47) then
            return v
          end
        end
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


