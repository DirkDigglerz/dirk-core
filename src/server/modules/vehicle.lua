Core.Vehicle = {
  Create = function(model,pos, cb, net)
    local veh = CreateVehicle(GetHashKey(model), pos.x,pos.y,pos.z -1.0,pos.w,true,net)
    cb(veh)
  end,

  AddKeys = function(p,veh,plate) --#' This is the function called to add keys for a vehicle you own. '
    if Config.KeySystem == "qb-vehiclekeys" then
      TriggerEvent('qb-vehiclekeys:server:GiveVehicleKeys',p, plate)
    elseif Config.KeySystem == "cd_garage" then
      TriggerClientEvent('cd_garage:AddKeys', tonumber(p), exports['cd_garage']:GetPlate(plate))
    elseif Config.KeySystem == "okokGarage" then
      TriggerServerEvent('okokGarage:GiveKeys', plate, p)    
    end
  end,

  Fix = function(p)
    TriggerClientEvent("Core:Vehicle:Fix", p)
  end,


  -- CreateStealable("Barnfind:2", {
  --   position = vector4(0,0,0,0),
    
  --   canSpawn = false, --#' Can this vehicle spawn? '
  --   Interactions = {
  --     Stealable = {willOwn = true, canSell = {}}
  --   }
  -- })

  CreateStealable = function(name,data)
    local self = {}
    self.name  = name
    self.model = model
  end  
}