Core.Player = {
  CurJob = {},

  Ready = function()
    if Config.UsingESX then
      while not ESX do Wait(500); end
      while not ESX.IsPlayerLoaded() do Wait(500); end
      return true
    elseif Config.UsingQBCore then
      while not QBCore do Wait(500); end
      while not QBCore.Functions.GetPlayerData().job do Wait(500); end
      return true
    end
    return true
  end,

  Job = function()
    print(json.encode(Core.Player.CurJob,{indent=true}))
    return Core.Player.CurJob
  end,

  Identifier = function()
    if Config.UsingESX then
      local data = ESX.GetPlayerData()
      return data.identifier
    elseif Config.UsingQBCore then
      local data = QBCore.Functions.GetPlayerData()
      return data.citizenid
    end
  end,

  Gang = function()
    if Config.UsingESX then return "None"; end
    if not Config.UsingQBCore then return false; end
    local data = QBCore.Functions.GetPlayerData()
    return data.gang.name
  end,

  GetJob = function()
    local jt = {}
    if Config.UsingESX then
      local data = ESX.GetPlayerData()
      jt.name  =  data.job.name
      jt.label =  data.job.label
      jt.rank  =  data.job.grade
      jt.rankL =  data.job.grade_label
      jt.IsCop = Config.PoliceJobs[data.job.name]
    elseif Config.UsingQBCore then
      local data = QBCore.Functions.GetPlayerData()
      jt.name  = data.job.name
      jt.label = data.job.label
      jt.rank  = data.job.grade.level
      jt.IsCop = Config.PoliceJobs[data.job.name]
    end
    Core.Player.CurJob = jt
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

if Config.UsingESX then
  RegisterNetEvent("esx:setJob", function(job)
    Core.Player.GetJob()
  end)
elseif Config.UsingQBCore then
  RegisterNetEvent('QBCore:Client:OnJobUpdate', function(job)
    Core.Player.GetJob()
  end)
end
