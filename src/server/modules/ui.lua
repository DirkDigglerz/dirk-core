Core.UI = {
  Notify = function(p,msg)
    if Config.Framework == "es_extended" then
      TriggerClientEvent("esx:showNotification", p, msg)
    elseif Config.Framework == "qb-core" then
      TriggerClientEvent("QBCore:Notify", p, msg)
    end
  end,
}