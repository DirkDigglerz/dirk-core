Core = {
  Callback = function(name,cb,...)
    if Config.Framework == "es_extended" then
      ESX.TriggerServerCallback(name,cb,...)
    elseif Config.Framework == "qb-core" then
      QBCore.Functions.TriggerCallback(name,cb,...)
    end
  end,

  tableLength = function(t)
    local c = 0 
    for k,v in pairs(t) do
      c = c + 1
    end
    return c
  end
}