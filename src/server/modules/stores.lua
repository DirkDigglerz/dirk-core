Core.Stores = {

  Register = function(id, options)
    local self       = {}
    self.ID          = id
    self.Name        = options.Name or "Unknown"
    self.Icon        = options.Icon or "fas fa-shopping-cart"
    self.Currency    = options.Currency or {Name = "Unknown", Symbol = "?", Type = "account", Value = "any"}
    self.Items       = options.Items or {}
    

    for index,data in pairs(self.Items) do 
      self.Items[index] = {
        Name  = data.Name,
        Label = Core.Inventory.GetItemLabel(data.Name),
        Price = data.Price,
        Img   = string.format("%s%s.png", Config.ItemsIconsDir, data.Name),
      }
    end

    self.ParsedItems = function()
      local ret = {}
      for _,d in pairs(self.Items) do
        ret[d.Name] = d
      end
      return ret
    end

    self.Checkout = function(ply, basket) 
      print(json.encode(basket, {indent = true}))
      --## Check this store sells all these items     
      local parsedItems = self.ParsedItems()
      for _,item in pairs(basket) do
        if not parsedItems[item.Name] then
          return "EXPLOIT", print('EXPLOITER?')
        else
          if item.Price/item.Amount ~= parsedItems[item.Name].Price then
            return "EXPLOIT", print('EXPLOITER?')
          end
        end

        if self.Currency == "item" then
          if not Core.Player.HasItem(ply, self.Currency.Value, item.Price) then
            return "CannotAfford", print('EXPLOITER?')
          end
          Core.Player.RemoveItem(ply, self.Currency.Value, item.Price)
        elseif self.Currency == "account" then
          if self.Currency.Value == "any" then 
            local account = Core.Player.HasMoney(ply, item.Price)
            if not account then
              return "CannotAfford", print('EXPLOITER?')
            end
            Core.Player.RemoveMoney(ply, account, item.Price)
          else
            if not Core.Player.HasMoneyInAccount(ply, self.Currency.Value, item.Price) then
              return "CannotAfford", print('EXPLOITER?')
            end
            Core.Player.RemoveMoney(ply, self.Currency.Value, item.Price)
          end

        end

        Core.Player.AddItem(ply, item.Name, item.Amount)
        return "Purchased", print('COMPLETE')
      end
    end

    Core.Stores[id] = self
  end,

  Callbacks = function()
    Core.Callback("Dirk-Core:Stores:Checkout", function(src,cb, store, items)
      local store = Core.Stores[store]
      assert(store, string.format("%s is trying to checkout from a store that's not been registered", GetInvokingResource()))
      cb(store.Checkout(src, items))
    end)

    Core.Callback("Dirk-Core:Stores:Open", function(src,cb, store)
      local store = Core.Stores[store]
      assert(store, string.format("%s is trying to open a store that's not been registered", GetInvokingResource()))
      cb({
        Name     = store.Name,
        Icon     = store.Icon,
        Items    = store.Items,
        Currency = store.Currency,
      })
    end)
  end
}



CreateThread(function()
  while not Config.Framework do Wait(500); end 
  while not Core do Wait(500); end
  while not Core.Stores do Wait(500); end
  Core.Stores.Callbacks();
end)




