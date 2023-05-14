Core.Vehicle = {
  Create = function(model,pos, cb, net)
    local veh = CreateVehicle(GetHashKey(model), pos.x,pos.y,pos.z -1.0,pos.w,true,net)
    cb(veh)
  end,

  -- CreateStealable("Barnfind:2", {
  --   position = vector4(0,0,0,0),
    
  --   canSpawn = false, --#' Can this vehicle spawn? '
  --   Interactions = {
  --     Stealable = {willOwn = true, w}
  --   }
  -- })

  CreateStealable = function(name,data)
    local self = {}
    self.name  = name
    self.model = model
  end  
}