Core.Files = {
  Save = function(filename, data)
    local resource = GetInvokingResource()
    print(string.format("^2Dirk-Core^7 | %s is saving ^3: %s^7", resource, filename))
    SaveResourceFile(GetCurrentResourceName(), string.format('saveddata/%s', filename), json.encode(data, {indent = true}))
  end,

  Load = function(filename)
    local resource = GetInvokingResource()
    print(string.format("^2Dirk-Core^7 | %s is loading ^3: %s^7", resource, filename))
    local data = json.decode(LoadResourceFile(GetCurrentResourceName(), string.format('saveddata/%s', filename)))
    return data
  end,

  TableToSQL = function(t)
    local output = "INSERT INTO `"..Config.ItemsDatabaseName.."` (`name`, `label`) VALUES"
    for k,v in pairs(t) do
      output = output..string.format("\n ('%s', '%s'),", k, v.label)
    end
    output = output..";"
    return output
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

  OXShared = function(input)
    local ret = {}
    for item,data in pairs(input) do
      ret[item] = {} 
      for k,v in pairs(data) do 
        if k == "label" or k == "weight" then 
          ret[item][k] = v
        end
      end
    end
    return ret
  end,

}

