Core.UI = {
  Notify = function(p,msg)
    if Config.UsingESX then
      TriggerClientEvent("esx:showNotification", p, msg)
    elseif Config.UsingQBCore then
      TriggerClientEvent("QBCore:Notify", p, msg)
    end
  end,
}