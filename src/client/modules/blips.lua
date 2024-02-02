Core.Blips = {
  Register = function(id,data)
    print("^2Dirk-Core^7 | Registering Blip: ^5"..id.."^7")
    print(json.encode(data, {indent = true}))
    local self = {}
    self.ID = id
    self.Area = data.Area or false
    self.Resource = data.Resource or GetInvokingResource()
    self.Pos = data.Pos or vector3(0,0,0)
    self.Display = data.Display or 4
    self.Scale = data.Scale or 1.0
    self.Color = data.Color or 0 
    self.ShortRange = data.ShortRange or true
    self.Text = data.Text or "Blip"
    self.Route = data.Route or false
    self.Sprite = data.Sprite or 1
    
    self.canSee = data.canSee

    self.render = function()
      local blip
      if not self.Area then 
        blip = AddBlipForCoord(self.Pos.x,self.Pos.y,self.Pos.z)
      elseif self.Area then
        blip = AddBlipForArea(self.Pos.x, self.Pos.y, self.Pos.z, self.Area.Width, self.Area.Height)
      end
      SetBlipSprite (blip, self.Sprite)
      SetBlipDisplay(blip, self.Display)
      SetBlipScale  (blip, self.Scale)
      SetBlipColour (blip, self.Color)
      SetBlipAsShortRange(blip, self.ShortRange)
      BeginTextCommandSetBlipName("STRING")
      AddTextComponentString(self.Text)
      EndTextCommandSetBlipName(blip)

      if data.Route then
        SetBlipRoute(blip,true)
      end
      self.Blip = blip
    end
    
    self.remove = function()
      RemoveBlip(self.Blip)
      self.Blip = nil 
    end

    self.delete = function()
      self.remove()
      Core.Blips[self.ID] = nil
    end

    Core.Blips[id] = self
    return self
  end,

  Get      = function(id)
    return Core.Blips[id]
  end,

  Edit     = function(id,data)
    local blip = Core.Blips[id]
    if blip then 
      blip.Display = data.Display or blip.Display
      blip.Scale = data.Scale or blip.Scale
      blip.Color = data.Color or blip.Color
      blip.ShortRange = data.ShortRange or blip.ShortRange
      blip.Text = data.Text or blip.Text
      blip.Route = data.Route or blip.Route
      blip.Sprite = data.Sprite or blip.Sprite
      blip.Pos = data.Pos or blip.Pos
      blip.canSee = data.canSee or blip.canSee
    end
    
    blip.remove()
    blip.render()
  end,
}



CreateThread(function()
  local typeOf = type
  while true do 
    local wait_time = 1000

    for k,v in pairs(Core.Blips) do 
      if typeOf(v) ~= "function" then 
        if v.canSee and v.canSee() then 
          if not v.Blip then 
            v.render()
          end
        else 
          if v.Blip then 
            v.remove()
          end
        end
      end
    end

    Wait(wait_time)
  end
end)

AddEventHandler("onResourceStop", function(resourceName)
  local count = 0  
  local typeOf = type
  for blipId,blipData in pairs(Core.Blips) do 
    if typeOf(blipData) ~= "function" then 
      count += 1
      if blipData.Resource == resourceName then 
        blipData.delete()
      end
    end
  end
  if count > 0 then 
    print("^2Dirk-Core^7 | Cleaned up ^5"..count.."^7 Blips for Resource: ^3"..resourceName.."^7")
  end
end)
