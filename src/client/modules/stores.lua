Core.Stores = {
  onClose = {},  
  Open = function(store, cb)
    Core.Callback("Dirk-Core:Stores:Open", function(res)
      assert(res,string.format("%s is trying to open a store that's not been registered", GetInvokingResource()))
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
    elseif resp == "EXPLOIT" then
      print('YOU BEING A NUISANCE?')
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