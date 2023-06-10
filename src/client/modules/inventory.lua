Core.Inventories = {}

RegisterNetEvent("Dirk:Inventory:Sync", function(id, data)
  Core.Inventories[id] = data
end)

Core.Inventory = {
  Open = function(id,data, type)
    if not type or type ~= "shop" then 
      local inv = Core.Inventories[id]
      data.Slots = tonumber(data.Slots)
      data.Weight = tonumber(data.Weight)
      if not inv then 
        print('CREATING NEW INV')
        TriggerServerEvent("Dirk:Inventory:Sync", id, data)
      else
        if (data.Slots ~= inv.Slots) or (data.Weight ~= inv.Weight) or (data.Name ~= inv.Name) then
          print('UPDATING INV')
          TriggerServerEvent("Dirk:Inventory:Sync", id, data)
        end
      end
      if Config.Inventory == "qb-inventory" or Config.Inventory == "lj-inventory" or Config.Inventory == "qs-inventory" then
        TriggerServerEvent("inventory:server:OpenInventory", "stash", id, {
          maxweight = data.Weight,
          slots     = data.Slots,
        })
        TriggerEvent("inventory:client:SetCurrentStash", id)
      elseif Config.Inventory == "mf-inventory" then
        exports["mf-inventory"]:openOtherInventory(id)
      elseif Config.Inventory == "ox_inventory" then
        print('Opening OX')
        exports.ox_inventory:openInventory('stash', id)
      end
    else
      if Config.Inventory == "qb-inventory" or Config.Inventory == "lj-inventory" or Config.Inventory == "qs-inventory" or Config.Inventory == "ox_inventory" then
        print('Opening Shop')
        print(json.encode(data.Items))
        TriggerServerEvent("inventory:server:OpenInventory", "shop", "Itemshop_" .. math.random(1111111,9999999), {
          items = data.Items,
          label = data.Name,
          slots = data.Slots,
        })
      end
    end
  end,
}

RegisterNetEvent("Dirk:Inventory:Open", function(id, data)
  Core.Inventory.Open(id, data)
end)
