



Core.UI = {
  ShowHelpNotification = function(msg)
    AddTextEntry(GetCurrentResourceName(), msg)

    if thisFrame then
      DisplayHelpTextThisFrame(GetCurrentResourceName(), false)
    else
      if beep == nil then beep = true end
      BeginTextCommandDisplayHelp(GetCurrentResourceName())
      EndTextCommandDisplayHelp(0, false, false, duration or -1)
    end
  end,

  Notify = function(msg, type, time)
    if Config.Framework == "es_extended" then
      ESX.ShowNotification(msg)
    elseif Config.Framework == "qb-core" then
      QBCore.Functions.Notify(msg, type, time or 5000)
    elseif Config.Framework == "vrp" then 
      TriggerEvent('Notify',"success",msg,5000)
    end
  end,

  OpenLink = function(link)
    SendNUIMessage({
      type        = "openLink",
      link        = link,
    })
  end,
  
  CopyToClipboard = function(val)
    SendNUIMessage({
      type        = "copy",
      value        = val,
    })
  end,

  ScreenToWorld = function(iter)
    local entityType,entitySubType
    local camRot = GetGameplayCamRot(0)
    local camPos = GetGameplayCamCoord()
    local posX = 0.5
    local posY = 0.5
    local cursor = vector2(posX, posY)
    local cam3DPos, forwardDir = Core.UI.ScreenRelToWorld(camPos, camRot, cursor)
    local direction = camPos + forwardDir * 50.0
    local rayHandle = StartShapeTestRay(cam3DPos.x,cam3DPos.y,cam3DPos.z, direction.x,direction.y,direction.z, (iter and -1 or 30), 0, 0)
    local _, hit, endCoords, surfaceNormal, entityHit = GetShapeTestResult(rayHandle)
    if entityHit <= 0 and not iter then
      return Core.UI.ScreenToWorld(true)
    end
    return hit, endCoords, entityHit
  end,

  CursorToWorld = function(iter)
    local entityType,entitySubType
    local camRot = GetGameplayCamRot(0)
    local camPos = GetGameplayCamCoord()
    local posX = GetControlNormal(0, 239)
    local posY = GetControlNormal(0, 240)
    local cursor = vector2(posX, posY)
    local cam3DPos, forwardDir = Core.UI.ScreenRelToWorld(camPos, camRot, cursor)
    local direction = camPos + forwardDir * 50.0
    local rayHandle = StartShapeTestRay(cam3DPos.x,cam3DPos.y,cam3DPos.z, direction.x,direction.y,direction.z, (iter and -1 or 30), 0, 0)
    local _, hit, endCoords, surfaceNormal, entityHit = GetShapeTestResult(rayHandle)
    if entityHit <= 0 and not iter then
      return Core.UI.CursorToWorld(true)
    end
    return hit, endCoords, entityHit
  end,

  ScreenRelToWorld = function(camPos, camRot, cursor)
    local camForward = Core.UI.RotationToDirection(camRot)
    local rotUp = vector3(camRot.x + 1.0, camRot.y, camRot.z)
    local rotDown = vector3(camRot.x - 1.0, camRot.y, camRot.z)
    local rotLeft = vector3(camRot.x, camRot.y, camRot.z - 1.0)
    local rotRight = vector3(camRot.x, camRot.y, camRot.z + 1.0)
    local camRight = Core.UI.RotationToDirection(rotRight) - Core.UI.RotationToDirection(rotLeft)
    local camUp = Core.UI.RotationToDirection(rotUp) - Core.UI.RotationToDirection(rotDown)
    local rollRad = -(camRot.y * math.pi / 180.0)
    local camRightRoll = camRight * math.cos(rollRad) - camUp * math.sin(rollRad)
    local camUpRoll = camRight * math.sin(rollRad) + camUp * math.cos(rollRad)
    local point3DZero = camPos + camForward * 1.0
    local point3D = point3DZero + camRightRoll + camUpRoll
    local point2D = Core.UI.World3DToScreen2D(point3D)
    local point2DZero = Core.UI.World3DToScreen2D(point3DZero)
    local scaleX = (cursor.x - point2DZero.x) / (point2D.x - point2DZero.x)
    local scaleY = (cursor.y - point2DZero.y) / (point2D.y - point2DZero.y)
    local point3Dret = point3DZero + camRightRoll * scaleX + camUpRoll * scaleY
    local forwardDir = camForward + camRightRoll * scaleX + camUpRoll * scaleY
    return point3Dret, forwardDir
  end,

  RotationToDirection = function(rotation)
    local x = rotation.x * math.pi / 180.0
    local z = rotation.z * math.pi / 180.0
    local num = math.abs(math.cos(x))
    return vector3((-math.sin(z) * num), (math.cos(z) * num), math.sin(x))
  end,

  World3DToScreen2D = function(pos)
    local _, sX, sY = GetScreenCoordFromWorldCoord(pos.x, pos.y, pos.z)
    return vector2(sX, sY)
  end,

  -- Keycode UI
  Keycode     = function(code, params)
    KeyCodeResponse = nil
    SetNuiFocus(true,true)
    SendNUIMessage({
      type = "openKeyPad",
      code = code,
      params = params or {},
    })
    while KeyCodeResponse == nil do Wait(250); end
    return KeyCodeResponse
  end,

  ProgressBar = function(s, cb)
    if Config.ProgressBar == "ox_lib" then
      local bar = lib.progressBar({
        duration = s.time,
        label = s.label,
        useWhileDead = false,
        canCancel = s.canCancel,
        disable = {
          move = false,
          car = s.disableControl,
          combat = s.disableControl,
        },
      })
      if cb then cb(bar); end
    elseif Config.ProgressBar == "progressbar" then
      local finished = false
      QBCore.Functions.Progressbar('Changeme', s.label, s.time, false, s.canCancel, {
        disableMovement = false,
        disableCarMovement = s.disableControl,
        disableMouse = false,
        disableCombat = s.disableControl,
          }, {}, {}, {}, function() 
          finished = true
          if cb then cb(true); end
          end, function()
          finished = true
          if cb then cb(false); end
      end)
      while not finished do Wait(0); end 
    elseif Config.ProgressBar == "rprogress" then 
      local finished = false
      exports['rprogress']:Custom({
        Async           = true,
        Duration        = s.time,
        Label           = s.label,
        canCancel       = s.canCancel,
        DisableControls = s.disableControl,
        onComplete = function(cancelled)
          if cancelled then cb(false); else cb(true); end
          finished = true
        end,
      })
      while not finished do Wait(0); end 
    end
  end,
  
  SimpleNotification = function(data)
    SendNUIMessage({
      type = "DisplayNotification",
      data = {
        ID      = data.ID or string.format("%s:%s", GetCurrentResourceName(), GetGameTimer()),
        Title   = data.Title or "Notification",
        Message = data.Message or "No Message",
        Icon    = data.Icon or "fas fa-info-circle",
        Time    = data.Time or 5,
        NoTimer = data.NoTimer or false,
      },
    })
  end,

  DeleteSimpleNotification = function(id)
    SendNUIMessage({
      type = "RemoveNotification",
      ID = id,
    })
  end,

  Current   = {},
  AdvancedHelpNotif = function(name, items)
    local now = GetGameTimer()
    if not Core.UI.Current[name] then 
      Core.UI.Current[name] = now; 
      SetNuiFocusKeepInput(true)
      SendNuiMessage(json.encode({
        type    = "show",
        name    = name,
        message = items,
      }))
    else
      Core.UI.Current[name] = now; 
    end
  end,

  Hide = function(name)
    SendNuiMessage(json.encode({
      type = "hide",
      name = name,
    }))
    SetNuiFocusKeepInput(false)
  end,

  PositionEntity = function(entity)
    local model = GetHashKey(entity)
    -- if not IsModelInCdimage(model) then Core.UI.Notify("Tried to use an invalid model in entity placer") return false; end
    local startTime = GetGameTimer()
    
    print('Requesting Model ', model)
    while not HasModelLoaded(model) do
      RequestModel(model)
      local now = GetGameTimer()
      if now - startTime > 15000 then
        Core.UI.Notify("Failed to load model in entity placer")
        return false
      end 
      Wait(0) 
    end
    local thisObject = CreateObject(model, 0,0,0,true,true,false)
    SetEntityAlpha(thisObject, 150, false)
    SetEntityCollision(thisObject, false, false)
    while true do 
      
      local ply = PlayerPedId()
      local plyCoords = GetEntityCoords(ply)
      local hit, testCoords, entityHit = Core.UI.ScreenToWorld(true)
      local rotation = GetEntityRotation(thisObject).z
      -- print('Hit ', hit)
      -- print('testCoords ', testCoords)
      if (testCoords ~= vector3(0,0,0) and entityHit ~= ply and (#(plyCoords - testCoords) <= 10.0)) then
        endCoords = testCoords 
        SetEntityVisible(thisObject, true)
        DrawSphere(endCoords.x,endCoords.y,endCoords.z, 0.1, 0,255,0, 0.7)
        SetEntityCoords(thisObject, endCoords.x,endCoords.y,endCoords.z)
      else
        SetEntityVisible(thisObject, false)
      end




        Core.UI.AdvancedHelpNotif("entityPlacer", {
          {
            label = "Place Object", 
            key   = "g"
          },
          {
            label = "Rotate Right",
            key   = "➡️"
          },
          {
            label = "Rotate Left",
            key   = "⬅️"
          },
          {
            label = "Cancel Placement",
            key   = "q"
          }
        })
      

        

      DisableControlAction(0,47)
      DisableControlAction(0,74)
      DisableControlAction(0,105)
      DisableControlAction(0,172)
      DisableControlAction(0,173)
      DisableControlAction(0,85)
      

      if IsDisabledControlJustPressed(0, 47) then 
        local objectCoords = GetEntityCoords(thisObject)
        local objectRotation = GetEntityRotation(thisObject)

        DeleteEntity(thisObject)
        return {
          coords = objectCoords,
          rotation = objectRotation,
        }
      elseif IsDisabledControlPressed(0, 175) then
        rotation = rotation + 0.5
        SetEntityRotation(thisObject, 0.0,0.0,rotation, 0, true)
      elseif IsDisabledControlPressed(0, 174) then
        rotation = rotation - 0.5
        SetEntityRotation(thisObject, 0.0,0.0,rotation, 0, true)
      elseif IsDisabledControlJustPressed(0, 85) then
        DeleteEntity(thisObject)
        return false
      end
      Wait(0)
    end
  end,

}





Citizen.CreateThread(function()
  while true do
    local wait_time = 50
      for k,v in pairs(Core.UI.Current) do 
        if k then wait_time = 0; end
        if (GetGameTimer() - v) >= 300 then
          Core.UI.Current[k] = nil
          Core.UI.Hide(k)
        end
      end
    Wait(wait_time)
  end
end)

RegisterNetEvent(string.format("%s:Notify", GetCurrentResourceName()), function(msg, type, time)
  Core.UI.Notify(msg, type, time)
end)

RegisterNetEvent("Dirk-Core:UI:SimpleNotify", function(data)
  Core.UI.SimpleNotification(data)
end)

RegisterNetEvent("Dirk-Core:UI:RemoveSimpleNotify", function(id)
  Core.UI.DeleteSimpleNotification(id)
end)

RegisterNUICallback("keyCodeResponse", function(data,cb)
  KeyCodeResponse = data.correct
  SetNuiFocus(false,false)
end)


RegisterCommand("Dirk-Core:EntityPlacer", function(source,args)
  local ret = Core.UI.PositionEntity(args[1])
  print('Position')
  print(ret.coords, ret.rotation)
  Core.UI.CopyToClipboard(json.encode(ret.coords))
end)
