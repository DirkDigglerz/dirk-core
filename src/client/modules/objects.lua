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


  CreatePhysical("obj:12312", {
    model        = "prop_cs_pamphlet_01",
    position     = vector3(0,0,0),
    interactions = {
      Search = true, 
      Carry  = true,
      Grab   = true,
    },
  })

end

  CreatePhysical = function(name,data) --## Will create a physical object in the world a player will spawn/despawn when they get close to 
    local self = {}
    self.name            = name 
    self.model           = data.model
    self.position        = data.position

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
        if Settings.TargetSystem ~= "drawText" then 
          self.removeTarget()
        end
        self.object = nil
      end
    end

    self.spawn = function()
      while not HasModelLoaded(self.hash) do RequestModel(self.hash) Wait(0); end 
      self.object = CreateObject(self.hash, self.position.x,self.position.y,self.position.z,false,true, false)
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
              if self.disabled then return false; end
              if self.metadata['searched'] then return false; end 
              if not self.interactions["Search"] then return false; end
            end,

            action      = function()

            end, 

            label       = "Search",
            icon        = "fas fa-search",
          },
          {
            canInteract = function()
              if self.disabled then return false; end
              if not self.interactions["Carry"] then return false; end
              return true
            end,

            action      = function()

            end, 

            label       = "Carry",
            icon        = "fas fa-search",
          },
          {
            canInteract = function()
              if self.disabled then return false; end
              if not self.interactions["Grab"] then return false; end
            end,

            action      = function()
              self.grab()
            end, 

            label       = "Grab",
            icon        = "fas fa-search",
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
      if not data.canSpawn and self.canSpawn ~= data.canSpawn then
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
        Core.Objects.Carrying = self.name
      end
    end

    self.drop = function()
      print('newPosition needs added')
      Core.Objects.Carrying = nil
      self.globalState({
        canSpawn = true, 
        position = newPosition,
      })
    end

    self.search = function()
      if not self.metadata.searched then
        --## Search Anim

        --## Reward Player
        TriggerServerEvent("Dirk-Core:Physicals:Searched", self.name)
      end
    end

    self.grab   = function()
      if not self.metadata.grabbed then 
        self.metadata.grabbed = true
        self.globalState({
          canSpawn = false, 
          metadata = self.metadata,
        })
        --## Grab Anim
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
  Core.Callback("Dirk-Core:Physicals:GetPhysicals", function(cb)
    for k,v in pairs(cb) do 
      Core.Objects.CreatePhysical(k,v)
    end
    dataLoaded = true
  end)

  while not dataLoaded do Wait(0); end
  
  while true do 
    local wait_time = 1000
    local ply = PlayerPedId()
    local pos = GetEntityCoords(ply)
    for k,v in pairs(Core.Objects.Physicals) do 
      if #(pos - v.position) <= 50.0 then 
        if not v.object then
          v.spawn()
        elseif v.object then 
          if not v.canSpawn then 
            v.despawn()
          else
            if Settings.TargetSystem == "drawText" then 
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
  end
end)