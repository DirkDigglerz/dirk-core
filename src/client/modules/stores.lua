Core.Stores = {
  onClose = {},  
  Open = function(store, cb)
    Core.Callback("Dirk-Core:Stores:Open", function(res)
      assert(res,string.format("%s is trying to open a store that's not been registered", GetInvokingResource()))
      if res == "noItemsToSell" then 
        if cb then cb(); end  
        return Core.UI.Notify(Labels[Config.Language].NoItemsToSell); 
      end
      SetNuiFocus(true,true)
      SendNuiMessage(json.encode({
        type = "openStore",
        fromGame = {
          Currency = res.Currency.Symbol,
          Language = Config.Language, 
          -- ItemsIconsDir = Config.ItemsIconsDir,
          Store    = {
            Name  = res.Name,
            ID    = store,
            Icon  = res.Icon,
            Items = res.Items,
            Type  = res.Type,
          },
        },
      }))
      Core.Stores.onClose[store] = cb
    end, store)
  end,
}



RegisterNUICallback("checkOut", function(data,cb)
  Core.Callback("Dirk-Core:Stores:Checkout", function(resp)
    if resp == "Purchased" then
      cb(true)
    elseif resp == "CannotAfford" then
      cb(false)
    elseif resp == "notEnoughItems" then 
      cb(false)
    elseif resp == "EXPLOIT" then
      cb(false)
    end
  end, data.ID, data.Items)
end)


RegisterNUICallback("closeStore", function(data,cb)
  SetNuiFocus(false,false)
  if Core.Stores.onClose[data.ID] then
    Core.Stores.onClose[data.ID]()
  end
  cb(true)
end)