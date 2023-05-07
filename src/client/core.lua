Core = {
  Callback = function(name,cb,...)
    if Config.UsingESX then
      ESX.TriggerServerCallback(name,cb,...)
    elseif Config.UsingQBCore then
      QBCore.Functions.TriggerCallback(name,cb,...)
    end
  end,
}