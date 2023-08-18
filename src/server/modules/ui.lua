Core.UI = {
  Notify = function(p,msg, type, time)
    if Config.Framework == "es_extended" then
      TriggerClientEvent("esx:showNotification", p, msg, type, time)
    elseif Config.Framework == "qb-core" then
      TriggerClientEvent("QBCore:Notify", p, msg, type, time)
    end
  end,
}
