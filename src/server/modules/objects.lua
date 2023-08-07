Core.Trunks = {
  Data = {},
  CreateNew = function(plate,data)
    local self = {}
    self.plate = plate
    self.items = data.items or {}
    self.class = data.vehicleClass or "Compacts"
    self.max   = data.max or Config.VehicleClassCapacities[data.vehicleClass] or 250

    self.save = function()
      Core.Files.Save("objectTrunks.json", Core.Trunks.Data)
    end

    self.canHold = function(weight)
      local weight = weight or 0
      local total = 0
      for k,v in pairs(self.items) do
        total = total + v.Weight
      end
      if total + weight <= self.max then
        return true
      end
      return false
    end

    self.addItem = function(item,amount)
      local amount = amount or 1
      if self.items[item.Name] then
        if self.canHold(item.Weight) then 
          self.items[item.Name] = {
            Label  =  self.items[item.Name].Label,
            Amount =  self.items[item.Name].Amount + amount,
            Weight = self.items[item.name].Weight + item.Weight,
          }
          self.save()
          return true
        end
      else
        if self.canHold(item.Weight) then 
          self.items[item.Name] = {
            Label  = item.Label,
            Amount =  1,
            Weight = item.Weight,
          }
           self.save()
          return true
        end
      end
      return false
    end

    self.removeItem = function(item,amount)
      if self.hasItem(item,amount) then 
        if self.items[item].Amount - amount <= 0 then 
          self.items[item] = nil
        else
          self.items[item] = {
            Label  = self.items[item].Label,
            Amount =  self.items[item].Amount - amount,
            Weight = self.items[item].Weight - (self.items[item].Weight/self.items[item].Amount),
          }
        end
        self.save()
        return true
      end
      return false
    end

    self.hasItem = function(item, amount)
      if self.items[item] and self.items[item].Amount >= amount then 
        return true
      end
      return false
    end

    self.searchTrunk = function(item,amount)
      for k,v in pairs(self.items) do 

      end
    end


    self.save()
    Core.Trunks.Data[plate] = self
  end,

  GetTrunk = function(plate)
    return Core.Trunks.Data[plate]
  end,
}


Core.Objects = {
  Physicals = {}, 

  Mass = {},

  GetPhysical = function(id)
    return Core.Objects.Physicals[id]
  end,

  CreateMassPhysical = function(table)
    for k,v in pairs(table) do 
      Core.Objects.CreatePhysical(k,v, true)
    end
    TriggerClientEvent("Dirk-Core:Physicals:CreateMass", -1, Core.Objects.Mass)
    Core.Objects.Mass = {}
  end,

  CreatePhysical = function(name,data, mass) --## Will create a physical object in the world a player will spawn/despawn when they get close to 
    local self = {}
    self.resource        = GetInvokingResource()
    self.name            = name 
    self.label           = data.label or "Nothing"
    self.model           = data.model
    self.position        = data.position
    self.interactions    = data.interactions or {}
    self.metadata        = data.metadata or {}
    self.canSpawn        = data.canSpawn or false
    self.canInteract     = data.canInteract or false
    self.placeOnGround   = true or data.placeOnGround

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
        local lootedAmount = 0 
        self.metadata.searched = true
        self.globalState({
          metadata = self.metadata,
        })
        for k,v in pairs(self.interactions.Search.Loot) do 
          math.randomseed(os.time() * math.random(1231))
          local chance = math.random(100)
          if chance <= v.chance then 
            if self.maxLoot and lootedAmount > self.maxLoot then return false; end 
            lootedAmount = lootedAmount + 1
            local newAmount = math.random(v.amount[1], v.amount[2])
            if v.item then 
              Core.Player.AddItem(src, v.item, newAmount, v.info)
            elseif v.account then 
              Core.Player.AddMoney(src, v.account, newAmount)
            end
          end
        end
      else
        Core.UI.Notify(src, "There is nothing in here.")
      end
    end

    self.placeInTrunk = function(src,plate, class)
      local trunk = Core.Trunks.GetTrunk(plate)
      if trunk then 
        if trunk.canHold(self.interactions.Carry.Weight) then 
          trunk.addItem({
            Model  = self.model, 
            Weight = self.interactions.Carry.Weight, 
            Label  = self.label, 
          }, 1) 
          return true
        else
          Core.UI.Notify(src, "This trunk is full.")
          return false
        end
      else
        --## Create Trunk if not one
        Core.Trunks.CreateNew(plate, {
          items = {
            [self.name] = {
              Label  = self.label,
              Amount = 1,
              Weight = self.interactions.Carry.Weight,
            },
          },
          class = class,
          max   = (Config.VehicleClassCapacities[class] or 250)
        })
        return true
      end
    end

    self.Grabbed = function(src)
      if not self.metadata.grabbed then 
        local lootedAmount = 0 
        for k,v in pairs(self.interactions.Grab.Loot) do 
          math.randomseed(os.time() * math.random(1231))
          local chance = math.random(100)
          if chance <= v.chance then 
            if self.maxLoot and lootedAmount > self.maxLoot then return false; end 
            lootedAmount = lootedAmount + 1
            local newAmount = math.random(v.amount[1], v.amount[2])
            if v.item then 
              Core.Player.AddItem(src, v.item, newAmount, v.info)
            elseif v.account then 
              Core.Player.AddMoney(src, v.account, newAmount)
            end
          end
        end
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
    if not mass then 
      TriggerClientEvent("Dirk-Core:Physicals:AddPhysical", -1, self.name, clientData)
    else
      Core.Objects.Mass[name] = clientData 
    end
    
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

RegisterNetEvent("Dirk-Core:Physicals:MassUpdate", function(table)
  for k,v in pairs(table) do 
    if Core.Objects.Physicals[k] then 
      for type,value in pairs(v) do 
        Core.Objects.Physicals[k][type] = value
      end
    end
  end
  TriggerClientEvent("Dirk-Core:Physicals:MassUpdate", -1, table)
end)



-- Probably not the best idea to let clients do this :shrug:
-- RegisterNetEvent("Dirk-Core:Physicals:AddPhysical", function(name,data)
--   if Core.Objects.Physicals[name] then Core.Objects.Physicals[name].remove(); end 
--   Core.Objects.CreatePhysical(name,data)
-- end)
-----------------------------------------------------------------------


Citizen.CreateThread(function()
  while not Config.Framework do Wait(500); end 
  Core.Callback("Dirk-Core:Physicals:GetPhysicals", function(source,cb)
    local ret = {}
    for k,v in pairs(Core.Objects.Physicals) do 
      if type(v) ~= "function" then 
        ret[k] = v
      end
    end
    cb(ret)
  end)
  Core.Objects.Trunks = Core.Files.Load("objectTrunks.json") or {};
  while not Core.Player do Wait(500); end
  Core.Callback("Dirk-Core:HasItem", function(src,cb,item,a)
    cb(Core.Player.HasItem(src, item,a))
  end)

  while not Core.Objects do Wait(500); end 
  Core.Callback("Dirk-Core:Physicals:PlaceInTrunk", function(source,cb, name, plate, class)
    if Core.Objects.Physicals[name] then 
      local canPlace = Core.Objects.Physicals[name].placeInTrunk(source, plate, class)
      while canPlace == nil do Wait(500); end
      cb(canPlace)
    end
  end)


  while not Core.Player do Wait(500); end
  Core.Callback("Dirk-Core:HasItem", function(src,cb,item,a, md)
    cb(Core.Player.HasItem(src, item,a, md))
  end)

end)