Core.Files = {
  Save = function(filename, data)
    SaveResourceFile(GetCurrentResourceName(), string.format('saveddata/%s', filename), json.encode(data, {indent = true}))
  end,

  Load = function(filename)
    local data = json.decode(LoadResourceFile(GetCurrentResourceName(), string.format('saveddata/%s', filename)))
    return data 
  end,

  TableToSQL = function(t)
    local output = "INSERT INTO `"..Config.ESXItemTable.."` (`name`, `label`) VALUES"
    for k,v in pairs(t) do 
      output = output..string.format("\n ('%s', '%s'),", k, v.label)
    end
    output = output.."\n;"
    return output
  end

}
