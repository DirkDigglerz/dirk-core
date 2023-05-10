Core = {
  States = {},

  ChangeState = function(name,data)
    Core.States[name] = data
  end,

  updateGlobalState = function(name,data)
    TriggerServerEvent("Dirk-Core:States:Update", name, data)
  end,

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

RegisterNetEvent("Dirk-Core:States:Update", function(name,data)
  Core.States.ChangeState(name,data)
end)

RegisterCommand("coreState", function(source,args)
  print(Core.States.HitPaleto, "Before")
  Core.ChangeState("HitPaleto", true)
 print(Core.States.HitPaleto, "After")
 
end)  