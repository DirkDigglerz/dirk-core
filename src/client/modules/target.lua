Core.Target = {
  AddBoxZone = function(name,data)
    if Config.TargetSystem == "qb-target" or Config.TargetSystem == "qtarget" then 
      exports[Config.TargetSystem]:AddBoxZone(name, vector3(data.Position.x, data.Position.y, data.Position.z), (data.Length or 1.0), (data.Width or 1.0), {
        name = name, -- This is the name of the zone recognized by PolyZone, this has to be unique so it doesn't mess up with other zones
        debugPoly = Config.DrawDebug, -- This is for enabling/disabling the drawing of the box, it accepts only a boolean value (true or false), when true it will draw the polyzone in green
        heading = (data.Position.w or 0.0),
        minZ = data.Position.z - 1.0,
        maxZ = data.Position.z + data.Height, 
      }, {
        options = data.Options,
        distance = (Distance or 1.5), -- This is the distance for you to be at for the target to turn blue, this is in GTA units and has to be a float value
      })
      return name
    elseif Config.TargetSystem == "ox_target" then 
      return exports['ox_target']:addBoxZone({
        coords = vector3(data.Position.x, data.Position.y, data.Position.z),
        size = vector3((data.Length or 1.0), (data.Width or 1.0), (data.Height or 1.0)),
        rotation = data.Position.w,
        debug = Config.DrawDebug,
        options = data.Options,
      })      
    end
  end, 

  DeleteZone = function(zn)
    if Config.TargetSystem == "qb-target" or Config.TargetSystem == "q-target" then 
      exports[Config.TargetSystem]:RemoveZone(zn)
    elseif Config.TargetSystem == "ox_target" then 
      exports['ox_target']:removeZone(zn)
    end
  end,
}