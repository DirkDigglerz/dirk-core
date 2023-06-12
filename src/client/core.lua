Core = {
  States = {},

  ChangeState = function(name,data)
    Core.States[name] = data
  end,

  updateGlobalState = function(name,data)
    TriggerServerEvent("Dirk-Core:States:Update", name, data)
  end,

  Callback = function(name,cb,...)
    if Config.Framework == "es_extended" then
      ESX.TriggerServerCallback(name,cb,...)
    elseif Config.Framework == "qb-core" then
      QBCore.Functions.TriggerCallback(name,cb,...)
    end
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

RegisterNetEvent("Dirk-Core:States:Update", function(name,data)
  Core.States.ChangeState(name,data)
end)

RegisterCommand("coreState", function(source,args)
  print(Core.States.HitPaleto, "Before")
  Core.ChangeState("HitPaleto", true)
 print(Core.States.HitPaleto, "After")
 
end)  