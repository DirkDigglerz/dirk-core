Core = {
  Callbacks = {},

  Callback = function(name,cb,...)
    Core.Callbacks[name] = cb
  end,

  ClientCallback = function(name, id, cb, ...)
    Core.Callbacks[name] = cb
    TriggerClientEvent("Dirk-Core:TriggerClientCallback", id, name, ...)
  end,
  
  SyncClientCallback = function(name,id, ...)
    local ret = nil 
    Core.ClientCallback(name, id, function(...)
      ret = {...}
    end, table.unpack({...}))
    while ret == nil do Wait(0); end
    return table.unpack(ret)
  end,

  CheckScriptVersion = function(script, myVersion)
    local versions = json.decode(LoadResourceFile(GetCurrentResourceName(), "scriptChangelogs.json"))
    if not versions[script] then return "This doesnt exist?"; end
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
      local failures = {}
      if Config.AutoAddItems then
        for k,v in pairs(toAdd) do
          local suc,msg = exports['qb-core']:AddItem(k,v)
          if not suc then failures[k] = msg; end 
        end
        for k,v in pairs(failures) do
          print("^2Dirk-Core^1 | AUTO ADD ITEM ERROR^7")
          print(string.format("%s couldn't be added because: %s", k,v))
        end
      end

    end
  end,

  Webhook = function(channel, name, embed)
    PerformHttpRequest(channel, function(err, text, headers) end, 'POST', json.encode({username = name, embeds = embed}), { ['Content-Type'] = 'application/json' })
  end,

  GetAllPlayers = function()
    if Config.Framework == "es_extended" then
      local players = {}
      local result = MySQL.query.await('SELECT firstname, lastname, dateofbirth, phone_number, identifier FROM users', {})
      for k,v in pairs(result) do
        if not v.firstname then v.firstname = "Unknown"; end 
        if not v.lastname then v.lastname = "Uknown"; end 
        local info = {
          name       = v.firstname.." "..v.lastname,
          identifier = v.identifier,
          dob        = v.dateofbirth or "NO DATE OF BIRTH",
          phone      = v.phone_number or json.decode(v.charinfo).phone or "UNKNOWN", 
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

  deepCloneTable = function(original)
    local cloned = {}
    
    for key, value in pairs(original) do
        if type(value) == "table" then
            cloned[key] = Core.deepCloneTable(value)  -- Recursive call for nested tables
        else
            cloned[key] = value  -- Copy non-table values directly
        end
    end
    
    return cloned
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


RegisterNetEvent("Dirk-Core:TriggerServerCallback", function(name, ...)
  local src = source
  if Core.Callbacks[name] then
    Core.Callbacks[name](src, function(...)
      TriggerClientEvent("Dirk-Core:ReturnServerCallback", src,  name, ...)
    end, ...)
  else
    TriggerClientEvent("Dirk-Core:ReturnServerCallback", src, "error", {
      cbName = name,
      error  = "This server has not registered this callback yet, are you using this correctly?",
    })
  end
end)

RegisterNetEvent("Dirk-Core:ClientReturnCallback", function(name,...)
  local args = ...
  if name == "error" then print(string.format("^2Dirk-Core^7\n^1ERROR^7\nResource: %s\nCallback: %s\n^1Error: %s^7", GetInvokingResource() or "dirk-core", args.cbName, args.error)); return; end
  if Core.Callbacks[name] then
    Core.Callbacks[name](...)
  end
end)

local eventLogs = {}
RegisterNetEvent("Dirk-Core:saveEventLogs", function(data)
  if Config.EventDebugger then 
    if data.playerId ~= -1 then return false; end     
    if not eventLogs[data.eventName] then eventLogs[data.eventName] = {}; end
    eventLogs[data.eventName].totalPayload = (eventLogs[data.eventName].totalPayload or 0) + (tonumber(data.payload) or 0)
    eventLogs[data.eventName].totalEvents = (eventLogs[data.eventName].totalEvents or 0) + 1
    eventLogs[data.eventName].averagePayload = eventLogs[data.eventName].totalPayload / eventLogs[data.eventName].totalEvents
  end
end)

if Config.EventDebugger then
  CreateThread(function()
    while not Core do Wait(500); end
    while not Core.Files do Wait(500); end
    eventLogs = Core.Files.Load("eventLogs.json") or {}
    while true do 
      Core.Files.Save("eventLogs.json", eventLogs)
      Wait(30000)
    end
  end)
end