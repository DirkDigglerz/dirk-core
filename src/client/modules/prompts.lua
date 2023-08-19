

local Menus = {}
local DisplayedOptions = {}
Core.Prompts = {
  Menus            = {},
  DisplayedOptions = {},
  Create = function(name,data)
    local self = {}
    self.Name     = name
    self.Options  = data.Options

    self.Distance = 1.5

    self.Pos      = data.Pos or nil 

    Core.Prompts.Menus[name] = self
  end,

  Open = function(name) --## Forces Open Menu
    for optID, optInfo in pairs(Core.Prompts.Menus[name].Options) do 
      local uniqueID = string.format("%s:%s", name, optID)
      if (optInfo.canInteract and optInfo.canInteract()) or not optInfo.canInteract then
        Core.Prompts.AddOption(uniqueID, optInfo)
      end
    end
  end,

  Close = function(name)
    for optID, optInfo in pairs(Core.Prompts.Menus[name].Options) do 
      local uniqueID = string.format("%s:%s", name, optID)
      Core.Prompts.RemoveOption(uniqueID)
    end
  end,

  AddOption = function(uniqueID, optInfo)
    local parsedOpt = {
      label   = optInfo.label,
      icon    = optInfo.icon,
      subtext = optInfo.subtext,
      click   = optInfo.click,
    }
    SendNuiMessage(json.encode({
      action = "addOption",
      uniqueID = uniqueID,
      Option   = parsedOpt, 
    }))
    Core.Prompts.DisplayedOptions[uniqueID] = optInfo.action or false
  end,

  RemoveOption = function(uniqueID)
    SendNuiMessage(json.encode({
      action = "removeOption",
      uniqueID = uniqueID,
    }))
    Core.Prompts.DisplayedOptions[uniqueID] = nil
  end,
}

local hasFocus = false
RegisterNuiCallback("click", function(data, cb)
  local uniqueID = data.uniqueID
  local action   = Core.Prompts.DisplayedOptions[uniqueID]
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
  if (Core.tableLength(Core.Prompts.DisplayedOptions)) == 0 then return; end
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
    if hasFocus then
      print('Disabling Controls')
      wait_time = 0 
      DisableAllControlActions(0)
      DisableAllControlActions(1)
      if pauseMenu then 
        SetCursorLocation(0.5, 0.5)
        SetNuiFocus(false,false)
        SetNuiFocusKeepInput(false)
        hasFocus = false
      end
      
    end

    for k,v in pairs(Core.Prompts.Menus) do 
      --## Position Based
      if v.Pos then 
        local dist = #(myCoords - v.Pos.xyz)
        if dist <= v.Distance then 
          if wait_time > 250 then wait_time = 250; end
          Core.Prompts.Menus[k].Open = true
          for optID, optInfo in pairs(v.Options) do 
            local uniqueID = string.format("%s:%s", v.Name, optID)
            local displaying = Core.Prompts.DisplayedOptions[uniqueID]
            if not pauseMenu then 
              if (optInfo.canInteract and optInfo.canInteract()) or not optInfo.canInteract then
                if not displaying then 
                  Core.Prompts.AddOption(uniqueID, optInfo)
                end
              else
                if displaying then 
                  Core.Prompts.RemoveOption(uniqueID)
                end
              end
            else
              if displaying then 
                Core.Prompts.RemoveOption(uniqueID)
              end
            end
          end
        elseif v.Open then 
          --## Close#
          Core.Prompts.Menus[k].Open = false
          
          hasFocus = false
          SetCursorLocation(0.5, 0.5)
          SetNuiFocus(false,false)
          SetNuiFocusKeepInput(false)
          
          
          for optID, optInfo in pairs(v.Options) do 
            local uniqueID = string.format("%s:%s", v.Name, optID)
            Core.Prompts.RemoveOption(uniqueID)
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






-- RegisterCommand('+dirkMouse', function()
--   print('SETTING FOCUS')
--   if hasFocus then return; end

--   SetCursorLocation(0.8, 0.5)
--   hasFocus = true
--   SetNuiFocus(true,true)
-- end, false)
-- RegisterCommand('-dirkMouse', function()
--   print('RELEASING')
--   if not hasFocus then return; end
--   hasFocus = false
--   SetNuiFocus(false,false)
-- end, false)
-- RegisterKeyMapping("+dirkMouse", "Enable Menu Mouse", "keyboard", Config.MenuMouseKey)
-- TriggerEvent('chat:removeSuggestion', '/+dirkMouse')
-- TriggerEvent('chat:removeSuggestion', '/-dirkMouse')