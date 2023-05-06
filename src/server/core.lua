Core = {
  Callback = function(name,route)
    if Config.UsingESX then
      ESX.RegisterServerCallback(name,route)
    elseif Config.UsingQBCore then
      QBCore.Functions.CreateCallback(name,route)
    end
  end,

  AddCommand = function(name,desc,func)
    if Config.UsingClassicCommand then
      RegisterCommand(name, function(source,args)
        func(source)
      end)
      return
    end

    if Config.UsingESX then
      ESX.RegisterCommand(name, Config.CommandPerms, function(xPlayer, args, showError)
        func(xPlayer.playerId)
      end, false, {help = desc})
    elseif Config.UsingQBCore then
      QBCore.Commands.Add(name, desc, {}, false, function(source)
        func(source)
      end, Config.CommandPerms)
    end
  end,

  AddAllItems = function(toAdd)
    if Config.UsingESX then
      if Config.AutoAddItems then
        local items = MySQL.query.await(string.format('SELECT * FROM %s',Config.ItemsDatabaseName), {})
        local indexed = {}
        for _,d in pairs(items) do
          indexed[d.name] = true
        end

        for k,v in pairs(toAdd) do
          if not indexed[k] then
            MySQL.insert('INSERT INTO items (name, label) VALUES (?, ?)', {k, v.label}, function(id)
              print('Item:',k, " has been added to your database because it was missing")
            end)
          end
        end
      end
    elseif Config.UsingQBCore then
      while not QBCore do Wait(500); end
      if Config.AutoAddItems then
        for k,v in pairs(toAdd) do
          local suc,msg = exports['qb-core']:AddItem(k,v)
          if not suc then print("There has been an error adding: ", k, " to your shared.lua because ", msg) Wait(15); end
        end
      end
    end
  end,

  TC = function(t)
    local c = 0
    for k,v in pairs(t) do
      if k and v then
        c = c + 1
      end
    end
    return c
  end,
}

