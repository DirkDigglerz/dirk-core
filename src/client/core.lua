
Core = {
  Callbacks = {},
  
  Await = function(func, msg, time)
    time = time or 5000
    local start_time = GetGameTimer()
    while not func() do 
      if GetGameTimer() - start_time > time then
        print(string.format("^2Dirk-Core^7 | %s timed out after ^3%s^7", msg, time))
        return false
      end
      Wait(0)
    end
    return val
  end,

  Callback = function(name,cb,...)
    Core.Callbacks[name] = cb
    TriggerServerEvent("Dirk-Core:TriggerServerCallback", name, ...)
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


  -- TableToText = function(tbl)
  --   local output = ""
  --   for k,v in pairs(tbl) do 
  --     output = type(k) ~= "number" and output.."[\""..k.."\"] = {" or output.."{"
  --     if type(v) == "table" then 
  --       output = output..Core.TableToText(v)
  --     elseif type(v) == "vector" then 
  --       local vectorType = (v.x and v.y and v.z and v.w) and "vector4" or (v.x and v.y and v.z) and "vector3" or v.x and v.y and "vector2" 
  --       output = output..string.format("%s(%s,%s,%s%s)", vectorType, v.x, v.y, v.z, v.w and ","..v.w or "").."\n"
  --     elseif type(v) == "boolean" then 
  --       output = output..tostring(v).."\n"
  --     elseif type(v) == "number" then
  --       output = output..v.."\n"
  --     else
  --       output = output..'"'..v..'"'.."\n"
  --     end
  --   end
  --   return output
  -- end,

  TableToText = function(table)
    local output = ""
    for k,v in pairs(table) do
      output = output.."['"..k.."']".." = {\n"
      for n,d in pairs(v) do
        if type(d) == "table" or type(d) == "vector" then
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
  end,

  findKeyInTables = function(tbls, key)

    local findInTable = function(tbl, key)
      for _key, data in pairs(tbl) do
        if type(data) == 'table' then
          local found = findInTable(data, key)
          if found then return found; end
        else
          if _key == key then return data; end
        end
      end
      return false
    end
  
    for _, table in pairs(tbls) do
      for _key, data in pairs(table) do 
        if type(data) == 'table' then
          local found = findInTable(data, key)
          if found then return found; end
        else
          if _key == key then return data; end
        end      
      end
    end
    return false
  end

}

RegisterNetEvent("Dirk-Core:TriggerClientCallback", function(name, ...)
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

RegisterNetEvent("Dirk-Core:ReturnServerCallback", function(name,...)
  local args = ...
  if name == "error" then print(string.format("^2Dirk-Core^7\n^1ERROR^7\nResource: %s\nCallback: %s\n^1Error: %s^7", GetInvokingResource() or "dirk-core", args.cbName, args.error)); return; end
  if Core.Callbacks[name] then
    Core.Callbacks[name](...)
  end
end)
