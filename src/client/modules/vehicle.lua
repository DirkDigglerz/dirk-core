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
      TriggerEvent('cd_garage:AddKeys', plate)
    elseif Config.KeySystem == "okokGarage" then
      TriggerServerEvent('okokGarage:GiveKeys', plate)
    end
  end,

  Properties = function(veh)
    if Config.Framework == "es_extended" then
      local props = ESX.Game.GetVehicleProperties(veh)
      return props
    elseif Config.Framework == "qb-core" then
      local props = QBCore.Functions.GetVehicleProperties(veh)
      return props
    end
  end,

  Plate = function(veh, fw)
    if fw and Config.Framework == "es_extended" then
      local plate = ESX.Math.Trim(GetVehicleNumberPlateText(veh))
      return plate
    elseif fw and Config.Framework == "qb-core" then
      local plate = QBCore.Functions.GetPlate(veh)
      return plate
    else
      local plate = GetVehicleNumberPlateText(veh)
      return plate
    end
  end, 

  SetPlate = function(veh, plate, fw)
    if fw and Config.Framework == "es_extended" then
      plate = ESX.Math.Trim(plate)
    elseif fw and Config.Framework == "qb-core" then
      plate = QBCore.Shared.Trim(plate)
    end
    return SetVehicleNumberPlateText(veh, plate)
  end,

  Fix = function()
    local p = PlayerPedId()
    local v = GetVehiclePedIsIn(p, false)
    if v ~= 0 then
      SetVehicleFixed(v)
      SetVehicleDeformationFixed(v)
      SetVehicleUndriveable(v, false)
      SetVehicleEngineOn(v, true, true)
      SetVehicleEngineHealth(v, 1000)
      SetVehiclePetrolTankHealth(v, 1000)
      SetVehicleDirtLevel(v, 0)
      SetVehicleOilLevel(v, 100.0)
    else 
      Core.UI.Notify("You are not in a vehicle")
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


RegisterNetEvent("Core:Vehicle:Fix", function()
  Core.Vehicle.Fix()
end)