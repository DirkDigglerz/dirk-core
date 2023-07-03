Core.Objects = {
  RenderEnts = {},
  Create = function(modelname, pos, network, cb)
    local model = GetHashKey(modelname)
    while not HasModelLoaded(model) do RequestModel(model) Wait(0); end
    local obj = CreateObject(model, pos.x,pos.y,pos.z,network,true, false)
    SetEntityHeading(obj, (pos['w'] or 0.0))
    cb(obj)
  end,

  AddRenderable = function(id, data, cb) --## Allows creation of local entites that will despawn and spawn within a render distance aswell as calling back when within a interact distance or when spawning/despawning so you can manipulat ein your own scripts
    local self = {}
    self.id = id
    self.model = data.model
    self.type  = data.type or "object"
    self.hash  = data.hash or nil
    self.entity = nil 
    self.network = data.network or false
    self.position = data.position or vector4(0,0,0,0)
    self.renderDist = data.renderDist or 100.0
    self.interactDist = data.interactDist or false
    self.spawnConditions = data.spawnConditions or {}

    self.spawn = function()
      local hash = self.hash or GetHashKey(self.model)
      while not HasModelLoaded(hash) do RequestModel(hash) Wait(0); end
      if self.type == "object" then 
        self.entity = CreateObject(hash, self.position.x,self.position.y,self.position.z, self.network, true, false)
      elseif self.type == "ped" then 
        self.entity = CreatePed(1, hash, self.position.x,self.position.y,self.position.z,self.position.w,self.network,false)
      elseif self.type == "vehicle" then 
        self.entity = CreateVehicle(hash, self.position.x,self.position.y,self.position.z,self.position.w,self.network,true)
      end


      SetModelAsNoLongerNeeded(hash)
      cb("spawn", {entity = self.entity})
    end

    self.despawn = function()
      DeleteEntity(self.entity)
      local oldEnt = self.entity
      self.entity = nil 
      cb("despawn", {entity = oldEnt})
    end

    self.withinDist = function(distance)
      cb("withinDist", {entity = self.entity, distance = distance})
    end

    self.remove = function()
      self.despawn()
      Core.Objects.RenderEnts[id] = nil
    end
    

    Core.Objects.RenderEnts[id] = self
    
    return true 
  end,

  RemoveRenderable = function(id)
    local render = Core.Objects.RenderEnts[id]
    if render then 
      render.remove()
    end
  end,

  Delete = function(ent)
    DeleteEntity(ent)
  end,

  Physicals = {}, 
  Holding   = {},

  DeleteHolding = function()
    ClearPedTasksImmediately(PlayerPedId())
    DeleteEntity(Core.Objects.Holding.object)
    Core.Objects.Holding = {}
  end,

  GetHolding = function()
    return Core.Objects.Holding
  end,

  GetPhysical = function(name)
    return Core.Objects.Physicals[name]
  end,

  CreatePhysical = function(name,data) --## Will create a physical object in the world a player will spawn/despawn when they get close to 
    local self = {}
    self.name            = name 
    self.label           = data.label or "Nothing"
    self.model           = data.model
    self.position        = data.position
    self.resource        = data.resource
    self.placeOnGround   = true or data.placeOnGround

    self.interactions    = data.interactions or {}
    self.metadata        = data.metadata or {}
    self.canSpawn        = data.canSpawn or false
    self.canInteract     = data.canInteract or true



    --## Client Variables
    self.hash            = GetHashKey(data.model)
    self.object          = nil



    --## Removes the entity right now and can be spawned again later
    self.despawn = function()
      if self.object then 
        DeleteEntity(self.object)
        if Config.TargetSystem ~= "drawText" then 
          self.removeTarget()
        end
        self.object = nil
      end
    end

    self.spawn = function()
      while not HasModelLoaded(self.hash) do RequestModel(self.hash) Wait(0); end 
      self.object = CreateObject(self.hash, self.position.x,self.position.y,self.position.z,false,true, false)
      SetEntityHeading(self.object, (self.position['w'] or 0.0))
      if self.placeOnGround then 
        PlaceObjectOnGroundProperly(self.object)
      end
      FreezeEntityPosition(self.object,true)
      SetModelAsNoLongerNeeded(self.hash)
      self.addTarget()
    end

    self.addTarget = function()
      Core.Target.AddEntity(self.object, {
        Local    = true, 
        Distance = 0.5,
        Options  = {
          {
            canInteract = function(entity, distance, data)
              if distance >= 1.35 then return false; end
              if not self.canInteract then return false; end
              if self.metadata['searched'] then return false; end 
              if not self.interactions["Search"] then return false; end
              return true
            end,

            action      = function()
              self.search()
            end, 

            label       = "Search",
            icon        = "fas fa-search",
          },
          {
            canInteract = function(entity, distance, data)
              if distance >= 1.35 then return false; end
              if not self.canInteract then return false; end
              if not self.interactions["Carry"] then return false; end
              return true
            end,

            action      = function() 
              self.carry()
            end, 

            label       = "Carry",
            icon        = "fas fa-people-carry-box",
          },
          {
            canInteract = function(entity, distance, data)
              if distance >= 1.35 then return false; end
              if not self.canInteract then return false; end
              if not self.interactions["Grab"] then return false; end
              return true
            end,

            action      = function()
              self.grab()
            end, 

            label       = "Grab",
            icon        = "fas fa-hands-holding-circle",
          },

        }
      })
    end

    self.removeTarget = function() --## Removes all target Options for this
      Core.Target.RemoveEntity(self.object)
    end

    self.disableSpawn = function()
      self.canSpawn = false
      self.despawn()
    end

    self.stateChange = function(data)
      if data.canSpawn == false and self.canSpawn == true then
        self.disableSpawn()
      end

      for k,v in pairs(data) do 
        self[k] = v
      end
    end

    self.globalState = function(data)
      TriggerServerEvent("Dirk-Core:Physicals:State", self.name, data)
    end

    --## Remove this entity from ever spawning will have to be called again to add it back to this table

    self.removePhysical = function()
      TriggerServerEvent("Dirk-Core:Physicals:RemovePhysical", self.name)
    end

    self.remove = function() --## Delete the object from the world and remove it from the table
      self.despawn()
      Core.Objects.Physicals[name] = nil
    end

    -------------------------------------------------------------------------------------------------

    self.carry = function()
      if not self.metadata.carried then 
        self.metadata.carried = true
        self.globalState({
          canSpawn = false, 
          metadata = self.metadata,
        })
        local ply = PlayerPedId()
        while not HasModelLoaded(self.hash) do RequestModel(self.hash) Wait(0); end
        local obj = CreateObject(self.hash, vector3(self.position.x, self.position.y, self.position.z), true,true,false)
        SetEntityAsMissionEntity(obj, true, true)
        SetModelAsNoLongerNeeded(self.hash)
        SetEntityHeading(obj,self.position.w)
        SetEntityVisible(obj,false)
        FreezeEntityPosition(obj,false)

        SetCurrentPedWeapon(ply, 0xA2719263)
        local bone = GetPedBoneIndex(ply, 28422)

        RequestAnimDict("anim@heists@load_box")
        while not HasAnimDictLoaded("anim@heists@load_box") do
          Citizen.Wait(10)
        end
        TaskPlayAnim(ply,"anim@heists@load_box","lift_box",1.0, -1.0, -1, 49, 0, 0, 0, 0)
        Wait(900)
        SetEntityVisible(obj,true)
        local carrySets = self.interactions.Carry
        AttachEntityToEntity(obj, ply, bone, (carrySets.oPos.x or 0.0), (carrySets.oPos.y or 0.0), (carrySets.oPos.z or 0.0), (carrySets.oRot.x or 0.0), (carrySets.oRot.y or 0.0), (carrySets.oRot.z or 0.0), 1, 1, 0, 0, 2, 1)
        Wait(900)
        RequestAnimDict("anim@heists@box_carry@")
        while not HasAnimDictLoaded("anim@heists@box_carry@") do Wait(10); end
        TaskPlayAnim(ply,"anim@heists@box_carry@","idle",1.0, -1.0, -1, 49, 0, 0, 0, 0)
        Wait(500)
        Core.Objects.Holding = {
          object = obj,
          name   = self.name,
          speed  = (self.interactions.Carry.WalkSpeed or 1.0)
        }
      end
    end

    self.drop = function()
      local oPos = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 1.0, -1.0)
      local h = GetEntityHeading(Core.Objects.Holding.object)
      local nPos = vector4(oPos.x,oPos.y,oPos.z, h)
      ClearPedTasksImmediately(PlayerPedId())
      ClearPedTasks(PlayerPedId())
      DeleteEntity(Core.Objects.Holding.object)
      Core.Objects.Holding = {}
      self.metadata.carried = false
      self.globalState({
        metadata = self.metadata,
        canSpawn = true, 
        position = nPos,
      })
    end

    self.search = function()
      if not self.metadata.searched then
        --## Search Anim
        local ply = PlayerPedId()
        FreezeEntityPosition(ply, true, true)
        TaskStartScenarioInPlace(ply, "PROP_HUMAN_BUM_BIN", 0, true)
        Wait(self.interactions.Search.Time * 1000)
        TaskStartScenarioInPlace(ply, "PROP_HUMAN_BUM_BIN", 0, false)
        Wait(100)
        FreezeEntityPosition(ply, false, false)
        ClearPedTasksImmediately(ply)
        --## Reward Player
        TriggerServerEvent("Dirk-Core:Physicals:Searched", self.name)
      end
    end

    self.grab   = function()
      if not self.metadata.grabbed then
        --## Grab Anim
        local ply = PlayerPedId()
        TaskTurnPedToFaceEntity(ply, self.object, 1500)
        local dict = "anim@heists@prison_heiststation@"
        RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) do Wait(10); end
        FreezeEntityPosition(ply, true)
        TaskPlayAnim(ply,dict,"pickup_bus_schedule",1.0, -1.0, -1, 49, 0, 0, 0, 0)
        Wait(1750)
        self.globalState({
          canSpawn = false, 
        })
        TriggerServerEvent("Dirk-Core:Physicals:Grabbed", self.name)
        Wait(750)
        ClearPedTasksImmediately(ply)
        FreezeEntityPosition(ply, false)      
      end
    end

    Core.Objects.Physicals[name] = self
    return self 
  end, 
}

RegisterNetEvent("Dirk-Core:Physicals:State", function(name, data)
  if Core.Objects.Physicals[name] then 
    Core.Objects.Physicals[name].stateChange(data)
  end
end)

RegisterNetEvent("Dirk-Core:Physicals:RemovePhysical", function(name)
  if Core.Objects.Physicals[name] then 
    Core.Objects.Physicals[name].remove()
  end
end)

RegisterNetEvent("Dirk-Core:Physicals:CreateMass", function(data)
  for k,v in pairs(data) do 
    Core.Objects.CreatePhysical(k,v)
  end
end)

RegisterNetEvent("Dirk-Core:Physicals:AddPhysical", function(name,data)
  if Core.Objects.Physicals[name] then Core.Objects.Physicals[name].remove(); end 
  Core.Objects.CreatePhysical(name,data)
end)

Citizen.CreateThread(function()
  while not Config.Framework do Wait(500); end
  while not Core.Player.Ready() do Wait(500); end
  while not Core.Target do Wait(500); end
  local dataLoaded = nil
  Core.Callback("Dirk-Core:Physicals:GetPhysicals", function(ret)
    for k,v in pairs(ret) do 
      Core.Objects.CreatePhysical(k,v)
    end
    dataLoaded = true
  end)
  while not dataLoaded do Wait(0); end
  local busy = nil
  Core.Target.AddGlobalVehicle({
    Distance = 1.5, 
    Options  = { 
      {
        canInteract = function(entity, distance, data,name, bone)
          if distance >= 1.0 then return false; end
          if busy or not Core.Objects.Holding.object then return false; end
          return true
        end,

        action = function(...)
          local argR = {...}
          local arg = argR[1]
          local _,class = Core.Vehicle.GetVehicleClass(arg.entity)
          local plate, varplate   = GetVehicleNumberPlateText(arg.entity)
          busy = true
          Core.Callback("Dirk-Core:Physicals:PlaceInTrunk", function(can)
            if can then 
              ClearPedTasksImmediately(PlayerPedId())
              ClearPedTasks(PlayerPedId())
              DeleteEntity(Core.Objects.Holding.object)
              Core.Objects.Holding = {}
              Core.Objects.Physicals[Core.Objects.Holding.name].metadata.carried = false
              Core.Objects.Physicals[Core.Objects.Holding.name].globalState({
                metadata = self.metadata,
                canSpawn = false, 
                position = nPos,
              })
            end
            busy = nil
          end, Core.Objects.Holding.name, plate, class)
        end,
        icon  = "fas fa-box-open",
        label = "Place Object",
      }
    },
  })

  while true do 
    local wait_time = 1000
    local ply = PlayerPedId()
    local pos = GetEntityCoords(ply)

    if Core.Objects.Holding.object then 
      wait_time = 0 
      SetPedMoveRateOverride(ply, tonumber(Core.Objects.Holding.speed))
      if not IsEntityPlayingAnim(ply, "anim@heists@box_carry@", "idle", 3) then
        TaskPlayAnim(ply,"anim@heists@box_carry@","idle",1.0, -1.0, -1, 49, 0, 0, 0, 0)
      end 

      Core.UI.AdvancedHelpNotif("CarryObject", {
        {
          key   = "g",
          label = "Drop Object",
        }
      })

      if IsControlJustPressed(0,47) then 
        Core.Objects.Physicals[Core.Objects.Holding.name].drop();
      end
    end

    for k,v in pairs(Core.Objects.Physicals) do 
      if #(pos - v.position.xyz) <= 50.0 then 
        if v.spawnConditions then 
          for name,data in pairs(v.spawnConditions) do 
            v.canSpawn = data.func(data.data, data.args) 
          end
        end
        if wait_time >= 500 then wait_time = 500; end 
        if not v.object and v.canSpawn then
          v.spawn()
        elseif v.object then 
          if not v.canSpawn then 
            v.despawn()
          else
            if Config.TargetSystem == "drawText" then 
              --## Check distance for drawText and put that logic here
            end
          end
        end
      else
        if v.object then 
          v.despawn()
        end
      end
    end
    Wait(wait_time)
  end
end)


Citizen.CreateThread(function()
  while not Core do Wait(500); end 
  while not Core.Objects do Wait(500); end 

  while true do 
    local wait_time = 0 
    local ply = PlayerPedId()
    local myPos = GetEntityCoords(ply)
    for k,v in pairs(Core.Objects.RenderEnts) do 
      local dist = #(myPos - v.position.xyz)
      if dist <= v.renderDist then 
        if not v.entity then
          v.spawn();
        else
          if (v.interactDist) and (dist <= v.interactDist) then 
            wait_time = 0 
            v.withinDist(dist)
          end
        end
      else
        if v.entity then
          v.despawn()          
        end
      end
    end
    Wait(wait_time)
  end
end)



RegisterNetEvent("Dirk-Core:Physicals:MassUpdate", function(table)
  for k,v in pairs(table) do 
    if Core.Objects.Physicals[k] then 
      for type,value in pairs(v) do 
        Core.Objects.Physicals[k][type] = value
      end
    end
  end
end)

RegisterNetEvent("onResourceStop", function(rN)
  local affected = 0 
  if Core.Objects.Holding.object then 
    DeleteEntity(Core.Objects.Holding.object)
  end
  if rN == GetCurrentResourceName() then 
    for k,v in pairs(Core.Objects.Physicals) do 
      v.remove()
      affected = affected + 1
    end

  else
    for k,v in pairs(Core.Objects.Physicals) do 
      if v.resource == rN then
        v.remove()
        affected = affected + 1
      end
    end
  end
  if affected > 0 then 
    print("^2Dirk-Core^7 | Cleaned up ^5"..affected.."^7 Physical Objects for resource: ^3"..rN.."^7")
  end
end)