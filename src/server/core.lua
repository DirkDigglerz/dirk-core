Core = {
  Callback = function(name,route)
    if Config.Framework == "es_extended" then
      ESX.RegisterServerCallback(name,route)
    elseif Config.Framework == "qb-core" then
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

    if Config.Framework == "es_extended" then
      ESX.RegisterCommand(name, Config.CommandPerms, function(xPlayer, args, showError)
        func(xPlayer.playerId)
      end, false, {help = desc})
    elseif Config.Framework == "qb-core" then
      QBCore.Commands.Add(name, desc, {}, false, function(source)
        func(source)
      end, Config.CommandPerms)
    end
  end,

  AddAllItems = function(toAdd)
    if Config.Framework == "es_extended" then
      if Config.AutoAddItems then
        local items = MySQL.query.await(string.format('SELECT * FROM %s',Config.ItemsDatabaseName), {})
        local indexed = {}
        for _,d in pairs(items) do
          indexed[d.name] = true
        end

        for k,v in pairs(toAdd) do
          if not indexed[k] then
            MySQL.insert(string.format('INSERT INTO %s (name, label) VALUES (?, ?)', Config.ItemsDatabaseName), {k, v.label}, function(id)
              print('Item:',k, " has been added to your database because it was missing")
            end)
          end
        end
      end
    elseif Config.Framework == "qb-core" then
      while not QBCore do Wait(500); end
      if Config.AutoAddItems then
        for k,v in pairs(toAdd) do
          local suc,msg = exports['qb-core']:AddItem(k,v)
          if not suc then print("There has been an error adding: ", k, " to your shared.lua because ", msg) Wait(15); end
        end
      end
    end
  end,

  GetAllPlayers = function()
    if Config.Framework == "es_extended" then
      local players = {}
      local result = MySQL.query.await('SELECT firstname, lastname, dateofbirth, phone_number, identifier FROM users', {})
      for k,v in pairs(result) do
        local info = {
          name       = v.firstname.." "..v.lastname,
          identifier = v.identifier,
          dob        = v.dateofbirth,
          phone      = v.phone_number or "UNKNOWN"
        }
        players[info.identifier] = info
      end
      return players
    elseif Config.Framework == "qb-core" then
      local players = {}
      local result = MySQL.query.await('SELECT charinfo, citizenid FROM players', {})
      for k,v in pairs(result) do
        local charinfo = json.decode(v.charinfo)
        local info = {
          name       = charinfo.firstname.." "..charinfo.lastname,
          identifier = v.citizenid,
          dob        = charinfo.birthdate,
          phone      = charinfo.phone
        }
        players[info.identifier] = info
      end
      return players
    end
    return {}
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

