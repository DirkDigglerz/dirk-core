Core.Objects = {

  Physicals = {}, 

  CreatePhysical = function(name,data) --## Will create a physical object in the world a player will spawn/despawn when they get close to 
    local self = {}
    self.name            = name 
    self.model           = data.model
    self.position        = data.position
    self.interactions    = data.interactions or {}


    self.metadata        = data.metadata or {}
    self.canSpawn        = data.canSpawn or false
    self.canInteract     = data.canInteract or false
    self.searchLoot      = data.searchLoot or {}
    self.grabLoot        = data.searchLoot or {}
    self.carrySettings   = data.carrySettings or {Weight = 150, oPos = vector3(0,0,0), oRot = vector3(0,0,0)}

    self.globalState = function(data)
      for k,v in pairs(data) do 
        self[k] = v
      end
      TriggerClientEvent("Dirk-Core:Physicals:State", -1, self.name, data)
    end

    --## Remove this entity from ever spawning will have to be called again to add it back to this table

    self.removePhysical = function()
      TriggerClientEvent("Dirk-Core:Physicals:RemovePhysical", -1, self.name)
      Core.Objects.Physicals[self.name] = nil
    end

    self.Searched = function(src)
      if not self.metadata.searched then 
        self.metadata.searched = true
        self.globalState({
          metadata = self.metadata,
        })
        --## Loop Search Loot
      else
        Core.UI.Notify(src, "There is nothing in here.")
      end
    end

    self.Grabbed = function(src)
      if not self.metadata.grabbed then 
        --## loop table
      else
        Core.UI.Notify(src, "There is nothing to grab here")
      end
    end

    Core.Objects.Physicals[name] = self

    local clientData = {}
    for k,v in pairs(self) do 
      if type(v) ~= "function" then 
        clientData[k] = v
      end
    end

    TriggerClientEvent("Dirk-Core:Physicals:AddPhysical", -1, self.name, clientData)
    return self 
  end, 
}

RegisterNetEvent("Dirk-Core:Physicals:Grabbed", function(name)
  local src = source
  if Core.Objects.Physicals[name] then 
    Core.Objects.Physicals[name].Grabbed(src)
  end
end)

RegisterNetEvent("Dirk-Core:Physicals:Searched", function(name)
  local src = source
  if Core.Objects.Physicals[name] then 
    Core.Objects.Physicals[name].Searched(src)
  end
end)

RegisterNetEvent("Dirk-Core:Physicals:State", function(name, data)
  if Core.Objects.Physicals[name] then 
    Core.Objects.Physicals[name].globalState(data)
  end
end)

RegisterNetEvent("Dirk-Core:Physicals:RemovePhysical", function(name)
  if Core.Objects.Physicals[name] then 
    Core.Objects.Physicals[name].removePhysical()
  end
end)

RegisterNetEvent("Dirk-Core:Physicals:AddPhysical", function(name,data)
  if Core.Objects.Physicals[name] then Core.Objects.Physicals[name].remove(); end 
  Core.Objects.CreatePhysical(name,data)
end)

Core.Callback("Dirk-Core:Physicals:GetPhysicals", function(source,cb)
  local ret = {}
  for k,v in pairs(Core.Objects.Physicals) do 
    if type(v) ~= "function" then 
      ret[k] = v
    end
  end
  cb(ret)
end)