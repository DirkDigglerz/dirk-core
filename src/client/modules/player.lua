Core.Player = {
  CurJob = {},

  Ready = function()
    if Config.Framework == "es_extended" then
      
      while not ESX do print('Hung at ESX') Wait(5000); end
      print(json.encode(ESX, {indent = true}))
      while not ESX.IsPlayerLoaded() do print('Hung at PLAYER LOADED') Wait(500); end
      print('Should return true')
      return true
    elseif Config.Framework == "qb-core" then
      while not QBCore do Wait(500); end
      while not QBCore.Functions.GetPlayerData().job do Wait(500); end
      return true
    end
    return true
  end,

  Job = function()
    return Core.Player.CurJob
  end,

  Identifier = function()
    if Config.Framework == "es_extended" then
      local data = ESX.GetPlayerData()
      return data.identifier
    elseif Config.Framework == "qb-core" then
      local data = QBCore.Functions.GetPlayerData()
      return data.citizenid
    end
  end,

  Gang = function()
    if Config.Framework == "es_extended" then return "None"; end
    if not Config.UsingQBCore then return false; end
    local data = QBCore.Functions.GetPlayerData()
    return data.gang.name
  end,

  IsCop = function()
    for k,v in pairs(Config.PoliceJobs) do
      if Core.Player.CurJob.name == k then
        return true
      end
    end
    return false
  end,

  GetJob = function()
    local jt = {}
    if Config.Framework == "es_extended" then
      local data = ESX.GetPlayerData()
      jt.name  =  data.job.name
      jt.label =  data.job.label
      jt.rank  =  data.job.grade
      jt.rankL =  data.job.grade_label
      jt.duty   = true
      jt.isBoss = false
      jt.isCop =  Config.PoliceJobs[data.job.name]
    elseif Config.Framework == "qb-core" then
      local data = QBCore.Functions.GetPlayerData()
      jt.name   = data.job.name
      jt.label  = data.job.label
      jt.rank   = data.job.grade.level
      jt.duty   = data.job.onduty
      jt.isBoss = data.job.isboss
      jt.isCop  = Config.PoliceJobs[data.job.name]
    end
    Core.Player.CurJob = jt
    return Core.Player.CurJob
  end,

  PlayAnim = function(data)
    while not HasAnimDictLoaded(data.dict) do RequestAnimDict(data.dict) Wait(0); end
    TaskPlayAnim(data.ent, data.dict, data.anim, 8.0, 8.0, -1, -1, -1, false, false, false)
    FreezeEntityPosition(data.ent, data.freeze)
    SetTimeout(data.time, function()
      ClearPedTasks(data.ent)
      if data.freeze then FreezeEntityPosition(data.ent, false); end
    end)
  end,
}

if Config.Framework == "es_extended" then
  RegisterNetEvent("esx:setJob", function(job)
    Core.Player.GetJob()
    TriggerEvent("Dirk-Core:JobChange", Core.Player.CurJob)
  end)
elseif Config.Framework == "qb-core" then
  RegisterNetEvent('QBCore:Client:OnJobUpdate', function(job)
    Core.Player.GetJob()
    TriggerEvent("Dirk-Core:JobChange", Core.Player.CurJob)
  end)
end

