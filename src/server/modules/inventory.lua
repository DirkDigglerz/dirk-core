Core.Inventories = {}

Core.Inventory = {
  Ready = false,
  UseableItem = function(name, cb)
    if Config.Framework == "es_extended" then
      ESX.RegisterUsableItem(name, function(source,item,extra, mf)
        cb(source,item,extra, mf)
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
    if not a and not b then return true; end -- both are nil
    if not a or not b then return false; end -- one is nil
    if type(a) ~= "table" or type(b) ~= "table" then return false; end
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
      elseif Config.Inventory == "ps-inventory" or Config.Inventory == "qb-inventory" or Config.Inventory == "lj-inventory" or (Config.Inventory == "qs-inventory" and not Config.NewQSInventory) then 
        local itemsCurrent = self.getItems()
        local takenSlots = {}
        for k,thisItem in pairs(itemsCurrent) do 
          takenSlots[tonumber(thisItem.slot)] = true
          if thisItem.name == item then 
            itemsCurrent[k].count = thisItem.count + amount
            self.updateDB(itemsCurrent)
            return true
          end
        end

        for i=1,32 do 
          if not takenSlots[tonumber(i)] then 
           
            if type(item) == "string" and QBCore.Shared.Items[item] then 
              itemsCurrent[#itemsCurrent+1] = {
                name = item, 
                label = QBCore.Shared.Items[item].label,
                count = amount, 
                info = info,
                slot = i, 
              }
              self.updateDB(itemsCurrent)
              return true
            end
          end
        end
        return false
      end
    end

    self.sanatize = function(items)
      local ret = {}
      for _,item in pairs(items) do 
        local itemInfo = QBCore.Shared.Items[item.name]
        if itemInfo then 
          ret[#ret + 1] = {
            name = itemInfo["name"],
            amount = tonumber(item.count),
            info = item.info or {},
            label = itemInfo["label"],
            -- description = itemInfo["description"] or "",
            weight = itemInfo["weight"],
            type = itemInfo["type"],
            unique = itemInfo["unique"],
            useable = itemInfo["useable"],
            image = itemInfo["image"],
            slot = item.slot,
          }
        end
      end
      return ret
    end

    self.updateDB = function(items)
      local sanitized = self.sanatize(items)
      MySQL.insert('INSERT INTO stashitems (stash, items) VALUES (:stash, :items) ON DUPLICATE KEY UPDATE items = :items', {
        ['stash'] = "Stash_"..self.id,
        ['items'] = json.encode(sanitized)
      })
    end
    
    self.removeItem = function(item,amount,info)
      if Config.Inventory == "ox_inventory" then
        local success, response = exports.ox_inventory:RemoveItem(self.id, item, amount, info or nil)
        return success,response
      elseif Config.Inventory == "ps-inventory" or Config.Inventory == "qb-inventory" or Config.Inventory == "lj-inventory" or (Config.Inventory == "qs-inventory" and not Config.NewQSInventory) then 
        if not self.hasItem(item,amount,info) then return false; end 
        local itemsCurrent = self.getItems()
        for k,v in pairs(itemsCurrent) do 
          if v.name == item then 
            local thisAmount = itemsCurrent[k].count
            if thisAmount <= amount then 
              itemsCurrent[k] = nil
            else
              itemsCurrent[k].count = thisAmount - amount
            end
          end
        end
        self.updateDB(itemsCurrent)
      end      
    end
    
    self.hasItem = function(item,amount,info)
      if Config.Inventory == "ox_inventory" then
        local count = exports.ox_inventory:GetItemCount(self.id, item, info, true)
        if count < amount then return false; end
        return count
      elseif Config.Inventory == "ps-inventory" or Config.Inventory == "qb-inventory" or Config.Inventory == "lj-inventory" or (Config.Inventory == "qs-inventory" and not Config.NewQSInventory) then 
        local itemsCurrent = self.getItems()
        for slot,thisItem in pairs(itemsCurrent) do 
          if thisItem.name == item and thisItem.count >= amount and (not info or Core.Inventory.CheckMatch(thisItem.info, info)) then return thisItem.count; end 
        end
        return false
      end
    end

    self.getItems = function()
      local ret = {}
      if Config.Inventory == "ox_inventory" then 
        local inv = exports.ox_inventory:GetInventory(self.id, false)
        if not inv then return ret, print('NO INVENTORY FOUND, ERROR?'); end
        local items =  inv.items
        for k,v in pairs(items) do 
          ret[#ret+1] = {
            name  = v.name,
            label = v.label,
            count = (v.amount or v.count),
            image = ("nui://%s%s.png"):format(Config.ItemsIconsDir, v.name),
            info  = (v.info or v.metadata or false),
          }
        end
        return ret
      elseif Config.Inventory == "ps-inventory" or Config.Inventory == "qb-inventory" or Config.Inventory == "lj-inventory" or (Config.Inventory == "qs-inventory" and not Config.NewQSInventory) then 
        local ret = {}
        local result = MySQL.scalar.await('SELECT items FROM stashitems WHERE stash = ?', {"Stash_"..self.id})
        if not result then return ret end
      
        local stashItems = json.decode(result)
        if not stashItems then return ret end
        for _, item in pairs(stashItems) do
          local itemInfo = QBCore.Shared.Items[item.name:lower()]
          if itemInfo then
            ret[#ret+1] = {
              name  = itemInfo["name"],
              label = itemInfo["label"],
              image = ("nui://%s%s.png"):format(Config.ItemsIconsDir, itemInfo["name"]),
              count = tonumber(item.amount),
              info  = item.info or "",
              slot  = item.slot, 
            }
          
          end
        end

        return ret
      end
      return ret
    end
    
    self.canHold = function(item,amount,info)
    
    end

    self.update = function(data)
      if Config.Inventory == "ox_inventory" then 
        exports.ox_inventory:SetMaxWeight(self.id, data.Weight)
        exports.ox_inventory:SetSlotCount(self.id, data.Slots)
      end
    end

    self.register = function(data)
      if Config.Inventory == "ox_inventory" then 
        exports.ox_inventory:RegisterStash(id, data.Label, data.Slots, data.Weight)
      end
    end
    
    self.clearInventory = function()
      if Config.Inventory == "ox_inventory" then
        exports.ox_inventory:ClearInventory(self.id)
      elseif Config.Inventory == "ps-inventory" or Config.Inventory == "qb-inventory" or Config.Inventory == "lj-inventory" or (Config.Inventory == "qs-inventory" and not Config.NewQSInventory) then 
        self.updateDB({})
      end
    end

    
    Core.Inventories[id] = self
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
  elseif Config.Inventory == "qs-inventory" and Config.NewQSInventory then

  end
end)
