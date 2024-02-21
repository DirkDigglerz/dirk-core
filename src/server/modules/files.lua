Core.Files = {
  Save = function(filename, data)
    local resource = GetInvokingResource()
    print(string.format("^2Dirk-Core^7 | %s is saving ^3: %s^7", resource or "dirk-core", filename))
    SaveResourceFile(GetCurrentResourceName(), string.format('saveddata/%s', filename), json.encode(data, {indent = true}))
  end,

  Load = function(filename)
    local resource = GetInvokingResource()
    print(string.format("^2Dirk-Core^7 | %s is loading ^3: %s^7", resource or "dirk-core", filename))
    local data = json.decode(LoadResourceFile(GetCurrentResourceName(), string.format('saveddata/%s', filename)))
    return data
  end,




  convertToVectors = function (table)
    local formattedTable = {}
    for key, value in pairs(table) do
      if type(value) == "table" and not value.x then
        formattedTable[key] = Core.Files.convertToVectors(value) -- Recursively call the function for nested tables
      else
        if type(value) == "table" and value.x and value.y and value.z and value.w then
          formattedTable[key] = vector4(value.x, value.y, value.z, value.w)
        elseif type(value) == "table" and value.x and value.y and value.z then
          formattedTable[key] = vector3(value.x, value.y, value.z)
        elseif type(value) == "table" and value.x and value.y then
          formattedTable[key] = vector2(value.x, value.y)
        else
          formattedTable[key] = value
        end
      end
    end
    return formattedTable
  end,

  TableToSQL = function(t)
    local tableCount = Core.TC(t)
    local output = "INSERT INTO `"..Config.ItemsDatabaseName.."` (`name`, `label`) VALUES"
    local currentNumber = 0
    for k,v in pairs(t) do
      currentNumber = currentNumber + 1
      output = output..string.format("\n ('%s', '%s')%s", k, v.label, currentNumber == tableCount and "" or ",")
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
        if k == "label" or k == "weight" or k == "stackable" then 
          if k ~= "stackable" then 
            ret[item][k] = v
          else
            ret[item]["stack"] = v
          end
        elseif k == 'image' then 
          ret[item].client = {
            image = v
          }
        end
      end
    end
    return ret
  end,

}

