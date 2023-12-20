Core.Stores = {

  Register = function(id, options)
    local self       = {}
    self.ID          = id
    self.Type        = options.Type or "Buy"
    self.Name        = options.Name or "Unknown"
    self.Icon        = options.Icon or "fas fa-shopping-cart"
    self.Currency    = options.Currency or {Name = "Unknown", Symbol = "?", Type = "account", Value = "any"}
    self.Items       = options.Items or {}
    

    for index,data in pairs(self.Items) do 
      self.Items[index] = {
        Name  = data.Name,
        Label = Core.Inventory.GetItemLabel(data.Name),
        Price = data.Price,
        Limit = data.Limit or nil,
        Img   = string.format("%s%s.png", Config.ItemsIconsDir, data.Name),
        Desc  = data.Desc or "No Description",
      }
    end

    self.ParsedItems = function()
      local ret = {}
      for _,d in pairs(self.Items) do
        ret[d.Name] = d
      end
      return ret
    end

    self.ParseSaleItems = function(ply)
      local ret = {}
      local myInv = Core.Player.Inventory(ply)
      for index,d in pairs(self.Items) do
        for k,v in pairs(myInv) do 
          if v.name == d.Name and v.count >= 1 then 
            ret[tonumber(index)] = d
            ret[tonumber(index)].Limit = v.count
          end
        end
      end
      return ret
    end


    self.Checkout = function(ply, basket) 
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


        if self.Type == "Sell" then
          if not Core.Player.HasItem(ply, item.Name, item.Amount) then return "notEnoughItems", print('EXPLOITER?'); end
          Core.Player.RemoveItem(ply, item.Name, item.Amount)
          if self.Currency.Type == "item" then
            Core.Player.AddItem(ply, self.Currency.Value, item.Price)
          elseif self.Currency.Type == "account" then 
            Core.Player.AddMoney(ply, self.Currency.Value, item.Price)
          end
        else
          if self.Currency.Type == "item" then
            local hasItem = Core.Player.HasItem(ply, self.Currency.Value, item.Price)
            if not hasItem then return "CannotAfford", print('EXPLOITER?'); end
            Core.Player.RemoveItem(ply, self.Currency.Value, item.Price)
          elseif self.Currency.Type == "account" then
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

        end
      end
      return "Purchased", print('COMPLETE')
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
      local items = {}
      if store.Type == "Sell" then 
        items = store.ParseSaleItems(src)
        local itemCount = Core.TC(items)
        if itemCount == 0 then return cb("noItemsToSell"); end
      else
        items = store.Items
      end

      cb({
        Name     = store.Name,
        Icon     = store.Icon,
        Items    = items,
        Currency = store.Currency,
        Type     = store.Type,
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




