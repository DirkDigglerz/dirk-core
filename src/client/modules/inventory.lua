Core.Inventory = {
  Open = function(id,data)
    if Config.StashSystem == "dirk" then
      Core.Callback("Dirk:Inventory:Open", function(invs)
        if invs then
          SetNuiFocus(true,true)
          FreezeEntityPosition(PlayerPedId(), true)
          SendNUIMessage({
            imageDir    = Config.ItemIconsDir,
            type        = "openInventory",
            inventories = invs,
          })
        else
          Core.UI.Notify(Labels[Config.Language].CantAccess)
        end
      end, id)
    elseif Config.StashSystem == "default" then
      if Config.Inventory == "qb-inventory" or Config.Inventory == "qs-inventory" then
        TriggerServerEvent("inventory:server:OpenInventory", "stash", id, {
          maxweight = data.Weight,
          slots     = data.Slots,
        })
        TriggerEvent("inventory:client:SetCurrentStash", id)
      elseif Config.Inventory == "mf-inventory" then
        exports["mf-inventory"]:openOtherInventory(id)
      elseif Config.Inventory == "ox_inventory" then
        exports.ox_inventory:openInventory('stash', id)
      end
    end
  end,

  Close = function(id)
    SetNuiFocus(false,false)
    TriggerServerEvent("Dirk:Inventory:Closed", id)
  end,

  Transfer = function(origin,target,item)
    TriggerServerEvent("Dirk:Inventory:Transfer", origin, target, item)
  end,
}

RegisterNUICallback("CloseInventory", function(data,cb)
  SetNuiFocus(false,false)
  FreezeEntityPosition(PlayerPedId(), false)
  Core.Inventory.Close(data.CurrentInventory)

end)

RegisterNUICallback("TransferInventory", function(data,cb)
   Core.Inventory.Transfer(data.Source, data.Target, data.Item) -- source, target, item
end)

RegisterNetEvent("Dirk:Inventory:Open", function(id)
  Core.Inventory.Open(id)
end)


-- RegisterCommand("CreateInventory", function(source,args)
--   TriggerServerEvent("Dirk:Inventory:CreateNew", '2323', {
--     Name = "Drug Labs Inventory",
--     Items   = {}
--   })
-- end)

-- RegisterCommand("oinv", function(source,args)
--   Core.Inventory.Open('2323')
-- end)