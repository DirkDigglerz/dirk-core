Core.Vehicle = {
  Create = function(model,pos, cb, net)
    while not Core.Game.LoadModel(model) do Wait(0); end
    local veh = CreateVehicle(GetHashKey(model), pos.x,pos.y,pos.z -1.0,pos.w,true,net)
    cb(veh)
  end,

  AddKeys = function(veh,plate) --#' This is the function called to add keys for a vehicle you own. '
    if Config.KeySystem == "qb-vehiclekeys" then
      TriggerServerEvent('qb-vehiclekeys:server:AcquireVehicleKeys', plate)
    elseif Config.KeySystem == "cd_garage" then
      TriggerEvent('cd_garage:AddKeys', exports['cd_garage']:GetPlate(plate))
    end
  end,

  VehClasses = {
    [0] = "Compacts",
    [1] = "Sedans",
    [2] = "SUVs",
    [3] = "Coupes",
    [4] = "Muscle",
    [5] = "Sports Classics",
    [6] = "Sports",
    [7] = "Super",
    [8] = "Motorcycles",
    [9] = "Off-road",
    [10] = "Industrial",
    [11] = "Utility",
    [12] = "Vans",
    [13] = "Cycles",
    [14] = "Boats",
    [15] = "Helicopters",
    [16] = "Planes",
    [17] = "Service",
    [18] = "Emergency",
    [19] =  "Military",
    [20] = "Commercial",
    [21] = "Trains",
  },

  GetVehicleClass = function(e)
    local nClass = GetVehicleClass(e)
    return nClass, Core.Vehicle.VehClasses[nClass]
  end
}