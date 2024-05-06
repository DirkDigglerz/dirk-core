local createdZones = {}

Core.Target = {
  Holding = {},
  AddBoxZone = function(name,data)
    local resource = GetInvokingResource() or 'dirk-core'
    if not createdZones[resource] then createdZones[resource] = {}; end
    createdZones[resource][name] = true

    for k,v in pairs(data.Options) do 
      if not v.distance then v.distance = (data.Distance or 1.5); end
    end  
    if Config.TargetSystem == "qb-target" or Config.TargetSystem == "qtarget" then
      exports[Config.TargetSystem]:AddBoxZone(name, vector3(data.Position.x, data.Position.y, data.Position.z), (data.Length or 1.0), (data.Width or 1.0), {
        name = name, -- This is the name of the zone recognized by PolyZone, this has to be unique so it doesn't mess up with other zones
        debugPoly = Config.DrawDebug, -- This is for enabling/disabling the drawing of the box, it accepts only a boolean value (true or false), when true it will draw the polyzone in green
        heading = (data.Position.w or 0.0),
        minZ = data.Position.z - 1.0,
        maxZ = data.Position.z + data.Height,
      }, {
        options = data.Options,
        distance = (data.Distance or 1.5), -- This is the distance for you to be at for the target to turn blue, this is in GTA units and has to be a float value
      })
      return name
    elseif Config.TargetSystem == "ox_target" then
      for k,v in pairs(data.Options) do
        data.Options[k].onSelect = v.action
        data.Options[k].distance = (data.Distance or 1.5)
      end
      local newTarget = exports['ox_target']:addBoxZone({
        coords = vector3(data.Position.x, data.Position.y, data.Position.z),
        size = vector3((data.Length or 1.0), (data.Width or 1.0), (data.Height or 1.0)),
        rotation = data.Position.w,
        debug = Config.DrawDebug,
        options = data.Options,
      })
      Core.Target.Holding[name] = newTarget
      return newTarget
    end
  end,

  AddPolyzone = function(name,data)
    local resource = GetInvokingResource() or 'dirk-core'
    print('adding polyzone', name, resource)
    if not createdZones[resource] then createdZones[resource] = {}; end
    createdZones[resource][name] = true
    if Config.TargetSystem == "qb-target" or Config.TargetSystem == "qtarget" or Config.TargetSystem == "ox_target" then
      if Config.TargetSystem == "ox_target" then tempTargetSystem = "qb-target" else tempTargetSystem = Config.TargetSystem;  end
      local minZ = 999999999
      for k,v in pairs(data.Polygon) do 
        data.Polygon[k] = vector2(v.x, v.y)
        if v.z <= minZ then minZ = v.z; end
      end

      for k,v in pairs(data.Options) do 
        if not v.distance then v.distance = (data.Distance or 1.5); end
      end
      
      local zone = exports[tempTargetSystem]:AddPolyZone(name, data.Polygon, {
        name = name, -- This is the name of the zone recognized by PolyZone, this has to be unique so it doesn't mess up with other zones
        debugPoly = Config.DrawDebug, -- This is for enabling/disabling the drawing of the box, it accepts only a boolean value (true or false), when true it will draw the polyzone in green
        minZ = minZ, -- This is the bottom of the polyzone, this can be different from the Z value in the coords, this has to be a float value
        maxZ = minZ + data.Height, -- This is the top of the polyzone, this can be different from the Z value in the coords, this has to be a float value
      }, {
        options = data.Options,
        distance = data.Distance, -- This is the distance for you to be at for the target to turn blue, this is in GTA units and has to be a float value
      })

      Core.Target.Holding[name] = zone
      return name
    end
  end,

  AddEntity = function(entity,data)
    if Config.TargetSystem == "qb-target" or Config.TargetSystem == "qtarget" then
      exports[Config.TargetSystem]:AddTargetEntity(entity, {
        options = data.Options,
        distance = (data.Distance or 1.5)
      })
    elseif Config.TargetSystem == "ox_target" then
      for k,v in pairs(data.Options) do
        data.Options[k].onSelect = v.action
        data.Options[k].distance = (v.distance or data.Distance or 1.5)
      end
      if not data.Local then
        return exports['ox_target']:addEntity(entity, data.Options)
      else
        return exports['ox_target']:addLocalEntity(entity, data.Options)
      end
    end
  end,

  RemoveEntity = function(entity, net)
    if Config.TargetSystem == "qb-target" or Config.TargetSystem == "qtarget" then
      exports[Config.TargetSystem]:RemoveTargetEntity(entity)
    elseif Config.TargetSystem == "ox_target" then
      if not net then
        exports.ox_target:removeLocalEntity(entity)
      else
        exports.ox_target:removeEntity(entity)
      end
    end
  end,

  AddGlobalVehicle = function(data)
    if Config.TargetSystem == "qb-target" then
      exports[Config.TargetSystem]:AddGlobalVehicle({
        distance = (data.Distance or 1.5),
        options  = data.Options,
      })
    elseif Config.TargetSystem == "qtarget" then 
      exports[Config.TargetSystem]:Vehicle({
        distance = (data.Distance or 1.5),
        options  = data.Options,
      })
    elseif Config.TargetSystem == "ox_target" then
      for k,v in pairs(data.Options) do
        data.Options[k].onSelect = v.action
        data.Options[k].distance = (v.distance or data.Distance or 1.5)
      end
      return exports.ox_target:addGlobalVehicle(data.Options)
    end
  end,

  AddGlobalPed = function(data)
    if Config.TargetSystem == "qb-target" then
      exports[Config.TargetSystem]:AddGlobalPed({
        distance = (data.Distance or 1.5),
        options  = data.Options,
      })
    elseif Config.TargetSystem == "qtarget" then 
      exports[Config.TargetSystem]:Ped({
        distance = (data.Distance or 1.5),
        options  = data.Options,
      })
    elseif Config.TargetSystem == "ox_target" then
      for k,v in pairs(data.Options) do
        data.Options[k].onSelect = v.action
        data.Options[k].distance = (v.distance or data.Distance or 1.5)
      end
      return exports.ox_target:addGlobalPed(data.Options)
    end
  end,

  AddModels    = function(data)
    if Config.TargetSystem == "qb-target" then
      exports[Config.TargetSystem]:AddTargetModel(data.Models, {
        distance = (data.Distance or 1.5),
        options  = data.Options,
      })
    elseif Config.TargetSystem == "qtarget" then 
      exports[Config.TargetSystem]:AddTargetModel(data.Models, {
        distance = (data.Distance or 1.5),
        options  = data.Options,
      })
    elseif Config.TargetSystem == "ox_target" then
      for k,v in pairs(data.Options) do
        data.Options[k].onSelect = v.action
        data.Options[k].distance = (v.distance or data.Distance or 1.5)
      end
      return exports.ox_target:addModel(data.Models, data.Options)
    end
  end,

  DeleteZone = function(zn)
    local resource = GetInvokingResource() or 'dirk-core'
    if not createdZones[resource] then return; end
    if not createdZones[resource][zn] then return; end
    createdZones[resource][zn] = nil
    if Config.TargetSystem == "qb-target" or Config.TargetSystem == "q-target" then
      exports[Config.TargetSystem]:RemoveZone(zn)
    elseif Config.TargetSystem == "ox_target" then
      print('deleting zone ', zn, Core.Target.Holding[zn])
      exports['ox_target']:removeZone(tonumber(Core.Target.Holding[zn]))
    end
  end,
}



AddEventHandler('onResourceStop', function(resource)
  print(json.encode(createdZones, {indent = true}))
  local count = 0 
  if createdZones[resource] then 
    for k,v in pairs(createdZones[resource]) do 
      Core.Target.DeleteZone(k)
      count = count + 1
    end
  end
  if count <= 0 then return; end
  print('^2Dirk-Core^7 | ^1Removed '..count..' target zone(s) from ^5'..resource..'^7')
end)  