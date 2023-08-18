Core.Licenses = {
  Registered = {},
  Players    = {},

  Register = function(license, info)
    Core.Licenses.Registered[license] = info
  end,

  HasLicense = function(ply,license)
    local plyId = Core.Player.Id(ply)
    if not Core.Licenses.Players[plyId] then return false; end
    return Core.Licenses.Players[plyId][license]
  end,

  State = function(ply,license,state)
    if not Core.Licenses.Registered[license] then return; end
    local plyId = Core.Player.Id(ply)
    if not Core.Licenses.Players[plyId] then Core.Licenses.Players[plyId] = {}; end
    Core.Licenses.Players[plyId][license] = state
    Core.UI.Notify(tonumber(ply), string.format("You have just %s your %s license", (state and "recieved" or "lost"),  Core.Licenses.Registered[license].Title or "Unknown")      )
    Core.Files.Save("licenses.json", Core.Licenses.Players)
  end,
}

RegisterNetEvent("Dirk-Core:LicenseState", function(license, state, ply)
  if not ply then ply = source; end 
  Core.Licenses.State(ply, license, state)
end)

CreateThread(function()
  while not Core do Wait(0); end
  while not Core.Callback do Wait(0); end
  Core.Callback("Dirk-Core:CheckLicense", function(src, cb, license, player)
    local outcome = Core.Licenses.HasLicense((player or src), license)
    cb(outcome)
  end)

  Core.Callback("Dirk-Core:GetTestInfo", function(src,cb, license)
    cb(Core.Licenses.Registered[license])
  end)

  while not Core.Files do Wait(500); end 
  Core.Licenses.Players = Core.Files.Load("licenses.json") or {}

  RegisterCommand("Dirk-Core:GiveLicense", function(source,args)
    local to = tonumber(args[1])
    local license = args[2]
    if not to or not license then return; end
    Core.Licenses.State(to, license, true)
  end, true)

  RegisterCommand("Dirk-Core:RevokeLicense", function(source,args)
    local to = tonumber(args[1])
    local license = args[2]
    if not to or not license then return; end
    Core.Licenses.State(to, license, false)
  end, true)
end)