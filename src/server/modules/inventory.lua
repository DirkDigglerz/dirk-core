Core.Inventories = {}

Core.Inventory = {
  Ready = false,
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

  GetItemLabel = function(name)
    if Config.Framework == "es_extended" then return ESX.GetItemLabel(name); end
    if Config.Framework == "qb-core" then
      if not QBCore.Shared.Items[name] then return "No Label"; end
      return QBCore.Shared.Items[name]['label']
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
    if not Core.Inventories[id] then 
      Core.Inventories[id] = Core.Inventory.Create(id)
      return Core.Inventories[id]
    end
   
  end,

  Create = function(id)
    local self = {}
    self.id = id

    self.addItem = function(item,amount,info)
      if Config.Inventory == "ox_inventory" then
        local success, response = exports.ox_inventory:AddItem(self.id, item, amount, info or nil)
        return success,response
      end
    end
    
    self.removeItem = function(item,amount,info)
      if Config.Inventory == "ox_inventory" then
        local success, response = exports.ox_inventory:RemoveItem(self.id, item, amount, info or nil)
        return success,response
      end      
    end
    
    self.hasItem = function(item,amount,info)
      if Config.Inventory == "ox_inventory" then
        local count = exports.ox_inventory:GetItemCount(self.id, item, info, true)
        if count <= amount then return false; end
        return true 
      end
    end
    
    self.canHold = function(item,amount,info)
    
    end
    
    self.clearInventory = function()
      if Config.Inventory == "ox_inventory" then
        exports.ox_inventory:ClearInventory(self.id)
      end
    end

    return self
  end,

}


RegisterNetEvent("Dirk:Inventory:Clear", function(id)
  local inv = Core.Inventory.GetById(id)
  inv.clearInventory()
end)

RegisterNetEvent("Dirk:Inventory:RegisterStash", function(id, data)
  if Config.Inventory == "ox_inventory" then 
    exports.ox_inventory:RegisterStash(id, data.Label, data.Slots, data.Weight)
  elseif Config.Inventory == "qs-inventory" and Config. then

  end
end)

Citizen.CreateThread(Core.Inventory.Load)