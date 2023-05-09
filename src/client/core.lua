Core = {
  Callback = function(name,cb,...)
    if Config.Framework == "es_extended" then
      ESX.TriggerServerCallback(name,cb,...)
    elseif Config.Framework == "qb-core" then
      QBCore.Functions.TriggerCallback(name,cb,...)
    end
  end,
}
if Config.Framework == "es_extended" then
  RegisterNetEvent("esx:setJob", function(job)
    Core.Player.GetJob()
  end)
elseif Config.Framework == "qb-core" then
  RegisterNetEvent('QBCore:Client:OnJobUpdate', function(job)
    Core.Player.GetJob()
  end)
end