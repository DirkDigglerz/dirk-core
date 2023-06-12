Core.Inventories = {}

Core.Inventory = {
  UseableItem = function(name, cb)
    if Config.Framework == "es_extended" then
      ESX.RegisterUsableItem(name, function(source,item,extra)
        cb(source,item,extra)
      end)
    elseif Config.Framework == "qb-core" then
      QBCore.Functions.CreateUseableItem(name, function(source, item, extra)
        cb(source,item, extra)
      end)
    end
  end,
  
  CheckMatch = function(a,b)
    for k,v in pairs(a) do
      if k ~= "quality" and (b[k] == nil or (b[k] ~= v)) then return false; end
    end
    return true
  end,

  GetById = function(id)
    if Core.Inventories[id] then return Core.Inventories[id]; end
    return false
  end,

  GetItemLabel = function(name)
    if Config.Framework == "es_extended" then return ESX.GetItemLabel(name); end
    if Config.Framework == "qb-core" then
      if not QBCore.Shared.Items[name] then return "No Label"; end
      return QBCore.Shared.Items[name]['label']
    end
  end,

  Load = function()
    local rawInventories = {}
    local data = Core.Files.Load("Inventories.json")
    if data then rawInventories = data; end
    for k,v in pairs(rawInventories) do
      Core.Inventory.CreateNew(k,v)
    end
  end,

  Save = function()
    local res = {}
    for name,data in pairs(Core.Inventories) do
      res[name] = {}
      for k,v in pairs(data) do 
        if type(v) ~= "function" then 
          res[name][k] = v
        end
      end
    end
    Core.Files.Save("Inventories.json", res)
  end,

  CreateNew = function(id,data)
    if Core.Inventories[id] then return false; end
    local self = {}
    self.id = id
    self.Name = data.Name or "Unknown"
    self.Slots = data.Slots or 32
    self.Weight = data.Weight or 50000
    self.Items = data.Items or {}
    
    self.updateInfo = function(newInfo)
      self.Name = newInfo.Name or self.Name
      self.Slots = newInfo.Slots or self.Slots
      self.Weight = newInfo.Weight or self.Weight
      self.Items = newInfo.Items or self.Items

      if Config.Inventory == "ox_inventory" then 
        local ox_inventory = exports.ox_inventory
        ox_inventory:SetMaxWeight(self.id, self.Weight)
        ox_inventory:SetSlotCount(self.id, self.Slots)
      elseif Config.Inventory == "qb-inventory" then 

      elseif Config.Inventory == "esx-inventory" then


      end
      -- Sync to all clients
      local ret = {}
      for k,v in pairs(self) do 
        if type(v) ~= "function" then 
          ret[k] = v
        end
      end
      Core.Inventory.Save()
      TriggerClientEvent("Dirk:Inventory:Sync", -1, id, ret)
    end

    self.addItem = function(item,amount,info)
      
    end

    self.removeItem = function(item,amount,info)

    end

    self.hasItem = function(item,amount,info)

    end

    self.canHold = function(item,amount,info)

    end

    self.clearInventory = function()
      if Config.Inventory == "ox_inventory" then
        exports.ox_inventory:ClearInventory(self.id)
      end
    end

  
    Core.Inventories[id] = self
    Core.Inventory.Save()
    TriggerClientEvent("Dirk:Inventory:Sync", -1, id, data)
  end,
}

RegisterNetEvent("Dirk:Inventory:Clear", function(id)
  local inv = Core.Inventory.GetById(id)
  inv.clearInventory()
end)

RegisterNetEvent("Dirk:Inventory:Sync", function(id,data)
  local inv = Core.Inventory.GetById(id)
  if not inv then 
    if Config.Inventory == "ox_inventory" then
      print('REgisteing Ox')
      exports.ox_inventory:RegisterStash(id, data.Name, data.Slots, data.Weight, false)
      Core.Inventory.CreateNew(id,data)
    elseif Config.Inventory == "qs-inventory" then
      exports['qs-inventory']:RegisterStash(source, "Stash_"..id, data.Slots, data.Weight) 
      Core.Inventory.CreateNew(id,data)
    elseif Config.Inventory == "mf-inventory" then
    
    elseif Config.Inventory == "qb-inventory" then
      
    end
  else
    inv.updateInfo(data)
  end
end)



Citizen.CreateThread(Core.Inventory.Load)