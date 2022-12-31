Core.Game = {
  LoadModel = function(m)
    local hash = GetHashKey(m)
    while not HasModelLoaded(hash) do RequestModel(hash) Wait(0); end
    return true
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
    SetBlipAsShortRange(blip, false)


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
      for k,v in pairs(pool) do
        local coords = GetEntityCoords(v)
        if #(pos - coords) <= 3.0 and IsPedAPlayer(v) then
          local hit, endCoords, entityHit = Core.UI.ScreenToWorld()
          if (endCoords ~= vector3(0,0,0) and entityHit ~= ply) then 
            lastTargLoc = endCoords   
          end
          if entityHit == v then 
            Core.UI.ShowHelpNotification("Press ~INPUT_THROW_GRENADE~ to select this player")
            if IsControlJustPressed(0,47) then 
              return v
            end
          end
        end
      end
      Wait(0)
    end
  end

}