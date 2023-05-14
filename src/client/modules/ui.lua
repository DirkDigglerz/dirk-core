



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

  Notify = function(msg)
    if Config.Framework == "es_extended" then
      ESX.ShowNotification(msg)
    elseif Config.Framework == "qb-core" then
      QBCore.Functions.Notify(msg)
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

  AddPrompt = function(id, opts)
    Prompts[id] = opts
  end,

  RemovePrompt = function(id)
    if currentPrompts[id] then
      ClosePrompt(id)
      currentPrompts[id] = nil
    end
    Prompts[id] = nil
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
      QBCore.Functions.Progressbar('Changeme', s.label, s.time, false, s.canCancel, {
        disableMovement = false,
        disableCarMovement = s.disableControl,
        disableMouse = false,
        disableCombat = s.disableControl,
          }, {}, {}, {}, function()
            if cb then cb(true); end
          end, function()
            if cb then cb(false); end
      end)
    end
  end,

  PlotPoints = function()
    local points = {}
    while true do
      local wait_time = 0
      local hit, endCoords, entityHit = Core.UI.ScreenToWorld()
      if (endCoords ~= vector3(0,0,0) and entityHit ~= ply) then
        DrawSphere(endCoords.x,endCoords.y,endCoords.z, 0.4, 255,0,0, 0.7)
        Core.UI.ShowHelpNotification("Press ~INPUT_CELLPHONE_CAMERA_GRID~ to add a point\nPress ~INPUT_CELLPHONE_CANCEL~ to delete last coordinate\nPress ~INPUT_CELLPHONE_CAMERA_DOF~ to finish")
        if IsControlJustPressed(0,183) then
          table.insert(points, endCoords)
        elseif IsControlJustPressed(0,177) then
          points[#points] = nil
        elseif IsControlJustPressed(0,185) then
          return points
        end
      end
      Wait(wait_time)
    end
  end,


  TableToText = function(table)
    local output = ""
    for k,v in pairs(table) do
      output = output.."['"..k.."']".." = {\n"
      for n,d in pairs(v) do
        if type(d) == "table" then
          output = output.."  ".."['"..n.."']".." = {\n"
            for i,m in pairs(d) do
              if type(m) == "boolean" then
                output = output.."    ".."['"..i.."']".." = "..tostring(m)..",\n"
              elseif type(m) == "number" then
                output = output.."    ".."['"..i.."']".." = "..m..",\n"
              else
                output = output.."    ".."['"..i.."']".." = '"..m.."',\n"
              end
            end
          output = output.."  },"
        elseif type(d) == "boolean" then
          output = output.."  ".."['"..n.."']".." = "..tostring(d)..","
        elseif type(d) == "number" then
          output = output.."  ".."['"..n.."']".." = "..d..","
        else
          output = output.."  ".."['"..n.."']".." = '"..d.."',"
        end
        output = output.."\n"
      end


      output = output.."\n},\n"
    end
    return output
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

RegisterNetEvent(string.format("%s:Notify", GetCurrentResourceName()), function(msg)
  Core.UI.Notify(msg)
end)


RegisterNUICallback("keyCodeResponse", function(data,cb)
  KeyCodeResponse = data.correct
  SetNuiFocus(false,false)
end)