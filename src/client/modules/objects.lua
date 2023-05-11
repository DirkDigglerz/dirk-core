Core.Objects = {
  Create = function(modelname, pos, network, cb)
    local model = GetHashKey(modelname)
    while not HasModelLoaded(model) do RequestModel(model) Wait(0); end
    local obj = CreateObject(model, pos.x,pos.y,pos.z,network,true, false)
    SetEntityHeading(obj, (pos['w'] or 0.0))
    cb(obj)
  end,

  Delete = function(ent)
    DeleteEntity(ent)
  end,

  Physicals = {}, 
  Holding   = {},

  CreatePhysical = function(name,data) --## Will create a physical object in the world a player will spawn/despawn when they get close to 
    local self = {}
    self.name            = name 
    self.label           = data.label or "Nothing"
    self.model           = data.model
    self.position        = data.position
    self.resource        = data.resource


    self.interactions    = data.interactions or {}
    self.metadata        = data.metadata or {}
    self.canSpawn        = data.canSpawn or false
    self.canInteract     = data.canInteract or true
    self.searchTime      = data.searchTime or (5000)


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
      FreezeEntityPosition(self.object,true)
      SetModelAsNoLongerNeeded(self.hash)
      self.addTarget()
    end

    self.addTarget = function()
      Core.Target.AddEntity(self.object, {
        Local    = true, 
        Distance = 1.5,
        Options  = {
          {
            canInteract = function()
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
            canInteract = function()
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
            canInteract = function()
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
        Wait(self.searchTime * 1000)
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
        canInteract = function()
          if busy or not Core.Objects.Holding.object then return false; end
          return true
        end,

        action = function(...)
          local arg = {...}
          local class = Core.Vehicle.GetVehicleClass(arg.entity)
          local plate = GetVehicleNumberPlateText(arg.entity)
          busy = true
          Core.Callback("Dirk-Core:Physicals:PlaceInTrunk", function(can)
            if can then 

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

RegisterNetEvent("onResourceStop", function(rN)
  local affected = 0 
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