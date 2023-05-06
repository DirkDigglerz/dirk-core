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


  GetCloseObject = function(model, pos, rad, mis)
    local obj = false
    local dis = false
    local obj = GetClosestObjectOfType(pos.x,pos.y,pos.z,rad,GetHashKey(model), mis)
    if obj then
      local obj_pos = GetEntityCoords(obj)
      dis = #(pos - obj_pos)
    end
    return obj, dis
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


  ChooseNearbyPlayer = function()
    Core.UI.Notify("Look at the player you wish to select")
    while true do
      local ply = PlayerPedId()
      local pos = GetEntityCoords(ply)
      local pool = GetGamePool('CPed')
      local nearby = {}
      local coords = GetEntityCoords(v)
      local hit, endCoords, entityHit = Core.UI.ScreenToWorld()

      if (endCoords ~= vector3(0,0,0) and entityHit ~= ply) then
        if entityHit == v then
          print(entityHit)
          Core.UI.ShowHelpNotification("Press ~INPUT_THROW_GRENADE~ to select this player")
          if IsControlJustPressed(0,47) then
            return v
          end
        end

      end


      Wait(0)
    end
  end

}