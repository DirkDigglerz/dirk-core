Core.Licenses = {
  Response = nil, 

  GetTestInfo = function(license)
    local ret = nil
    Core.Callback("Dirk-Core:GetTestInfo", function(questions)
      ret = questions
    end, license)
    while ret == nil do Wait(0); end
    return ret
  end,

  SitTest = function(license)
    if not Core.Licenses.HasLicense(license) then
      local testInfo = Core.Licenses.GetTestInfo(license)
      SendNuiMessage(json.encode({
        action    = "openLicenseTest", 
        title     = testInfo.Title,
        minPass   = testInfo.PassMark,
        questions = testInfo.Questions,
      }))
      SetNuiFocus(true, true)
      while Core.Licenses.Response == nil do Wait(0); end
      SetNuiFocus(false, false)
      local response = Core.Licenses.Response
      Core.Licenses.Response = nil
      if response == "Pass" then 
        TriggerServerEvent("Dirk-Core:LicenseState", license, true) --## Log this players quiz result
      elseif response == "Fail" then
        Core.UI.Notify("You have failed the test")
      elseif response == "Quit" then
        Core.UI.Notify("You have failed to complete the test")
      end
      return response
    else
      Core.UI.Notify("You already have this license")
    end
  end,

  HasLicense = function(license, player)
    local hasLicense = nil
    local res = nil
    Core.Callback("Dirk-Core:CheckLicense", function(has)
      hasLicense = has
      res = true
    end, license, player)
    while res == nil do Wait(0); end
    return hasLicense
  end
}

RegisterNUICallback("testResult", function(data)
  Core.Licenses.Response = data.result
end)