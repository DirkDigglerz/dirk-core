Core.Vehicle = {
  Create = function(model,pos, cb, net)
    local veh = CreateVehicle(GetHashKey(model), pos.x,pos.y,pos.z -1.0,pos.w,true,net)
    cb(veh)
  end,
}