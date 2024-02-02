

local Menus = {}
local hasFocus = false
local DisplayedOptions = {}
Core.Menus = {
  Menus            = {},
  DisplayedOptions = {},
  Register = function(name,data)
    local self = {}
    self.Name     = name
    self.InvokingResource = GetInvokingResource()
    self.Options  = data.Options
    self.Distance = data.Distance or 1.5
    self.Pos      = data.Pos or nil 

    Core.Menus.Menus[name] = self
  end,

  Remove = function(name)
    Core.Menus.Close(name)
    Core.Menus.Menus[name] = nil
  end,

  ToggleHide = function(name, bool)
    Core.Menus.Menus[name].Hidden = bool
    if bool then 
      Core.Menus.Close(name)
    end
  end,


  Open = function(name) --## Forces Open Menu
    if not Core.Menus.Menus[name] then return; end
    for optID, optInfo in ipairs(Core.Menus.Menus[name].Options) do 
      local uniqueID = string.format("%s:%s", name, optID)
      if (optInfo.canInteract and optInfo.canInteract()) or not optInfo.canInteract then
        Core.Menus.AddOption(uniqueID, optInfo)
      end
    end
  end,

  Close = function(name)
    if not Core.Menus.Menus[name] then return; end
    SetNuiFocus(false,false)
    hasFocus = false
    for optID, optInfo in pairs(Core.Menus.Menus[name].Options) do 
      local uniqueID = string.format("%s:%s", name, optID)
      Core.Menus.RemoveOption(uniqueID)
    end
  end,

  AddOption = function(uniqueID, optInfo)
    local parsedOpt = {
      label   = optInfo.label,
      icon    = optInfo.icon,
      subtext = optInfo.subtext,
      click   = optInfo.action or nil,
    }
    SendNuiMessage(json.encode({
      action = "addOption",
      uniqueID = uniqueID,
      Option   = parsedOpt, 
    }))
    Core.Menus.DisplayedOptions[uniqueID] = optInfo.action or false
  end,

  RemoveOption = function(uniqueID)
    if hasFocus then 
      SetNuiFocus(false,false)
      hasFocus = false
    end
    SendNuiMessage(json.encode({
      action = "removeOption",
      uniqueID = uniqueID,
    }))
    Core.Menus.DisplayedOptions[uniqueID] = nil
  end,
}


RegisterNuiCallback("click", function(data, cb)
  local uniqueID = data.uniqueID
  local action   = Core.Menus.DisplayedOptions[uniqueID]
  if action then 
    action({
      removeFocus = function()
        SetCursorLocation(0.5, 0.5)
        hasFocus = false
        SetNuiFocus(false,false)
        SetNuiFocusKeepInput(false)
        SetCursorLocation(0.5, 0.5)
      end,
    })
  end
end)


RegisterCommand('dirkMouse', function()
  if (Core.tableLength(Core.Menus.DisplayedOptions)) == 0 then return; end
  if hasFocus then
    SetCursorLocation(0.5, 0.5)
    SetNuiFocus(false,false)
    SetNuiFocusKeepInput(false)
    
    SetTimeout(500, function() hasFocus = false; end)
  else
    hasFocus = true
    SetCursorLocation(0.8, 0.5)
    SetNuiFocus(true,true)
    SetNuiFocusKeepInput(true)
    
  end
end, false)

RegisterKeyMapping("dirkMouse", "Enable Menu Mouse", "keyboard", Config.MenuMouseKey)
TriggerEvent('chat:removeSuggestion', '/dirkMouse')

local disableKeys = {18, 24, 69, 92, 106, 122, 135, 142, 144, 176, 223, 229, 237, 257, 329, 346}


CreateThread(function()
  while true do 
    local wait_time = 1000
    local ply = PlayerPedId()
    local myCoords = GetEntityCoords(ply)
    local pauseMenu = IsPauseMenuActive()
    local invOpen = LocalPlayer.state.invOpen
    if hasFocus then
      wait_time = 0 
      DisableAllControlActions(0)
      DisableAllControlActions(1)
      if pauseMenu or invOpen then 
        SetCursorLocation(0.5, 0.5)
        SetNuiFocus(false,false)
        SetNuiFocusKeepInput(false)
        hasFocus = false
      end
    end

    for k,v in pairs(Core.Menus.Menus) do 
      --## Position Based
      if v.Pos then 
        local dist = #(myCoords - v.Pos.xyz)
        if dist <= v.Distance and not v.Hidden then 
          if wait_time > 250 then wait_time = 250; end
          Core.Menus.Menus[k].Open = true
          for optID, optInfo in pairs(v.Options) do 
            local uniqueID = string.format("%s:%s", v.Name, optID)
            local displaying = Core.Menus.DisplayedOptions[uniqueID] ~= nil
            if not pauseMenu and not invOpen then 
              if (optInfo.canInteract and optInfo.canInteract()) or not optInfo.canInteract then
                if not displaying then 
                  Core.Menus.AddOption(uniqueID, optInfo)
                end
              else
                if displaying then 
                  Core.Menus.RemoveOption(uniqueID)
                end
              end
            else
              
              if displaying then 
                Core.Menus.RemoveOption(uniqueID)
              end
            end
          end
        elseif v.Open then 
          --## Close#
          Core.Menus.Menus[k].Open = false
          
          hasFocus = false
          SetCursorLocation(0.5, 0.5)
          SetNuiFocus(false,false)
          SetNuiFocusKeepInput(false)
          
          
          for optID, optInfo in pairs(v.Options) do 
            local uniqueID = string.format("%s:%s", v.Name, optID)
            Core.Menus.RemoveOption(uniqueID)
          end
        end
      end

      --## LOCAL Entity Based
      if v.LocalEnt then 
  
      end

    end
    Wait(wait_time)
  end
end)

AddEventHandler("onResourceStop", function(resource)
  local count = 0
  for k,v in pairs(Core.Menus.Menus) do 
    if v.InvokingResource == resource then 
      Core.Menus.Close(k)
      Core.Menus.Menus[k] = nil
      count = count + 1
    end
  end
  if count > 0 then print("^2Dirk-Core^7 | Cleaned up ^5"..count.."^7 Menus for resource: ^3"..resource.."^7"); end
end)
