Core.Vehicle = {
  Create = function(model,pos, cb, net)
    local veh = CreateVehicle(GetHashKey(model), pos.x,pos.y,pos.z -1.0,pos.w,true,net)
    cb(veh)
  end,

  AddKeys = function(p,veh,plate) --#' This is the function called to add keys for a vehicle you own. '
    if Config.KeySystem == "qb-vehiclekeys" then
      exports['qb-vehiclekeys']:GiveKeys(p, plate)
    elseif Config.KeySystem == "cd_garage" then
      TriggerClientEvent('cd_garage:AddKeys', tonumber(p), plate)
    elseif Config.KeySystem == "okokGarage" then
      TriggerEvent('okokGarage:GiveKeys', plate, p)    
    end
  end,

  Fix = function(p)
    TriggerClientEvent("Core:Vehicle:Fix", p)
  end, 
}