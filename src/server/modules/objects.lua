

Core.Objects = {
  Trunks = {},
  CreateNew = function(plate,data)
    local self = {}
    self.plate = plate
    self.items = data.items or {}
    self.class = data.vehicleClass or "Compacts"
    self.max   = data.max or Config.VehicleClassCapacities[data.vehicleClass] or 250

    self.save = function()
      Core.Files.Save("objectTrunks.json", Core.Objects.Trunks)
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
        else
          return false
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
        else 
          return false
        end
      end
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
    Core.Objects.Trunks[plate] = self
  end,

  GetTrunk = function(plate)
    return Core.Objects.Trunks[plate]
  end,

  Physicals = {}, 

  CreatePhysical = function(name,data) --## Will create a physical object in the world a player will spawn/despawn when they get close to 
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
    self.searchTime      = data.searchTime or (1000 * 5)
    self.maxLoot         = data.maxLoot or 1

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
        for k,v in pairs(self.interactions.Search) do 
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

    self.placeInTrunk = function(plate, class)
      local trunk = Core.Objects.GetTrunk(plate)
      if trunk then 
        if trunk.canHold(self.Interactions.Carry.Weight) then 
          if trunk.addItem({
            Model  = self.model, 
            Weight = self.Interactions.Carry.Weight, 
            Label  = self.label, 
          }, 1) then 
            self.removePhysical()
          end
        else
          Core.UI.Notify(src, "This trunk is full.")
        end
      else
     
      end
    end

    self.Grabbed = function(src)
      if not self.metadata.grabbed then 
        local lootedAmount = 0 
        for k,v in pairs(self.interactions.Grab) do 
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

Core.Callbac("Dirk-Core:Physicals:PlaceItemInTrunk", function(source,cb, name, plate, class)
  if Core.Objects.Physicals[name] then 
    local canPlace = Core.Objects.Physicals[name].placeInTrunk(plate, class)
    while not canPlace do Wait(500); end
    cb(canPlace)
  end
end)

RegisterNetEvent("Dirk-Core:Physicals:PlaceItemInTrunk", function(name, plate, class)

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

  while not Core.Inventories do Wait(500); end
  Core.Callback("Dirk:Inventory:Open", function(src,cb,id)
    local tInv = Core.Inventory.GetById(id)
    if not tInv then cb(nil, nil) return false; end
    if tInv.inUse then cb(nil,nil) return false; end
    tInv.ChangeUse(true)
    local invs = {
      {
        id = "Player",
        label = "My Inventory",
        items = cleanse(Core.Player.Inventory(src)),
      },
      {
        id = tInv.ID,
        label = tInv.Name,
        items = cleanse(tInv.Items),
      },
    }
    cb(invs)
  end)
end)