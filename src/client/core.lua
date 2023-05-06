Core = {
  Callback = function(name,cb,...)
    if Config.UsingESX then
      ESX.TriggerServerCallback(name,cb,...)
    elseif Config.UsingQBCore then
      QBCore.Functions.TriggerCallback(name,cb,...)
    end
  end,
}

if Config.UsingESX then
  RegisterNetEvent("esx:setJob", function(job)
    Core.Player.GetJob()
  end)
elseif Config.UsingQBCore then
  RegisterNetEvent('QBCore:Client:OnJobUpdate', function(job)
    Core.Player.GetJob()
  end)
end

