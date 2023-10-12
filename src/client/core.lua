
Core = {
  Callbacks = {},
  Callback = function(name,cb,...)
    if Config.Framework == "es_extended" then
      ESX.TriggerServerCallback(name,cb,...)
    elseif Config.Framework == "qb-core" then
      QBCore.Functions.TriggerCallback(name,cb,...)
    end
  end,

  ClientCallback = function(name,cb,...)
    Core.Callbacks[name] = cb
  end,

  SyncCallback = function(name,...)
    local ret = nil
    Core.Callback(name, function(...)
      ret = {...}
    end, table.unpack({...}))
    while ret == nil do Wait(0); end
    return table.unpack(ret)
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

  TableToText = function(table)
    local output = ""
    for k,v in pairs(table) do
      output = output.."['"..k.."']".." = {\n"
      for n,d in pairs(v) do
        if type(d) == "table" then
          output = output.."  ".."['"..n.."']".." = {\n"
            for i,m in pairs(d) do
              if type(m) == "boolean" then
                output = output.."    ".."['"..i.."']".." = "..tostring(m)..",\n"
              elseif type(m) == "number" then
                output = output.."    ".."['"..i.."']".." = "..m..",\n"
              else
                output = output.."    ".."['"..i.."']".." = '"..m.."',\n"
              end
            end
          output = output.."  },"
        elseif type(d) == "boolean" then
          output = output.."  ".."['"..n.."']".." = "..tostring(d)..","
        elseif type(d) == "number" then
          output = output.."  ".."['"..n.."']".." = "..d..","
        else
          output = output.."  ".."['"..n.."']".." = '"..d.."',"
        end
        output = output.."\n"
      end


      output = output.."\n},\n"
    end
    return output
  end,

  tableLength = function(t)
    local c = 0 
    for k,v in pairs(t) do
      c = c + 1
    end
    return c
  end
}

RegisterNetEvent("Dirk-Core:TriggerClientCallback", function(name, ...)
  print('Server has triggered this callback')
  print(json.encode({...}))
  if Core.Callbacks[name] then
    Core.Callbacks[name](function(...)
      TriggerServerEvent("Dirk-Core:ClientReturnCallback", name, ...)
    end, ...)
  else
    TriggerServerEvent("Dirk-Core:ClientReturnCallback", "error", {
      cbName = name,
      error  = "This client has not registered this callback yet, are you using this correctly?",
    })
  end
end)

Core.ClientCallback("testCB", function(cb, ret1,ret2)
  cb("return Fire", "return Fire2")
end)
