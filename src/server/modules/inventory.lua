Core.Inventories = {}

Core.Inventory = {
  Load = function()
    local rawInventories = {}
    local data = Core.Files.Load("Inventories.json")
    if data then rawInventories = data; end
    for k,v in pairs(rawInventories) do 
      Core.Inventory.CreateNew(k,v)
    end
  end,

  Save = function()
    local res = {}
    for k,v in pairs(Core.Inventories) do 
      res[k] = {
        Items    = v.Items, 
        Name     = v.Name,
      }
    end
    Core.Files.Save("Inventories.json", res)
  end,
  
  CreateNew = function(inv, data)
    local self = {}
    
    self.Items = (data.Items or {})
    self.Name  = (data.Name or string.format("Inventory:%s", math.random(1111111,9999999999)))
    self.inUse = false
    self.ID    = inv

    self.ChangeUse = function(s)
      self.inUse = s
    end
  
    self.HasItem = function(i,a,d)

      if d then 
        for k,v in pairs(self.Items) do 
          if i == v.name and (v.info and Core.Inventory.CheckMatch(d, v.info)) then 
            return true
          end
        end
      else
        for k,v in pairs(self.Items) do 
          if v.name == i and (v.count >= a) then
            return true
          end
        end
      end
    end
      
      
    self.AddItem = function(i,l,a,d)
      if d then 
        table.insert(self.Items, {
          label = l, 
          name  = i, 
          count = 1, 
          info  = d, 
        })
        Core.Inventory.Save()
        return true
      else
        for k,v in pairs(self.Items) do 
          if v.name == i then 
            self.Items[k].count = self.Items[k].count + a
            Core.Inventory.Save()
            return true 
          end
        end
        table.insert(self.Items, {
          label = l, 
          name  = i, 
          count = a, 
        })          
        Core.Inventory.Save()
        return true
      end
    end
  
    self.RemoveItem = function(i,a,d)
      if self.HasItem(i,a) then 
        for k,v in pairs(self.Items) do 
          if v.name == i then 
            if not d then 
              if v.count >= a then 
                self.Items[k].count = self.Items[k].count - a
                if self.Items[k].count == 0 then table.remove(self.Items, k); end
                Core.Inventory.Save()
                return true
              end
            else
              if (v.info and Core.Inventory.CheckMatch(d,v.info)) then 
                Core.Inventory.Save()
                table.remove(self.Items, k)
                return true
              end
            end
          end
        end
      end
      return false
    end
    
    self.TransferItem = function(i,a,d, t)
      if not Core.Inventories[t] then return false; end 
      if not self.HasItem(i,a,d) then return false; end
      self.RemoveItem(i,a,d)
      local inv = Core.Inventory.GetById(t)
      inv.AddItem(i,a,d)
    end 
    
    self.ClearInventory = function()
      self.Items = {}
    end 
    
    Core.Inventories[inv] = self
  end,    
  
  CheckMatch = function(a,b)
    for k,v in pairs(a) do 
      if b[k] == nil or (b[k] ~= v) then return false; end 
    end
    return true
  end,
  
  GetById = function(id)
    if Core.Inventories[id] then return Core.Inventories[id]; end
    return false
  end,
  
}

RegisterNetEvent("Dirk:Inventory:CreateNew", function(id, data)
  local inv = Core.Inventory.GetById(id)
  if inv then return false; end
  Core.Inventory.CreateNew(id,data) 
  Core.Inventory.Save()
end)

RegisterNetEvent("Dirk:Inventory:Clear", function(id)
  local inv = Core.Inventory.GetById(id)
  inv.ClearInventory()
end)

RegisterNetEvent("Dirk:Inventory:Transfer", function(src,target,item)
  local sInv = Core.Inventory.GetById(src)
  if src ~= "Player" and target ~= "Player" then 
    if not sInv then return false; end 
    sInv.TransferItem(item.name, item.count, (item.info or nil), target)
    return true
  else
    if src ~= "Player" then 
        -- Remove from non player inventory 
      if not sInv.HasItem(item.name, item.count, (item.info or nil)) then return false; end
      sInv.RemoveItem(item.name,item.count, (item.info or nil))
    else
      -- Remove From Player Inventory if can't then cancel. 
      if not Core.Player.RemoveItem(source,item.name,item.count, (item.info or nil)) then return false; end 
    end

    if target ~= "Player" then 
      -- Add Item to Inventory
      local tInv = Core.Inventory.GetById(target)
      if not tInv then return false; end 
      tInv.AddItem(item.name, item.label, item.count, (item.info or nil))
    else

      -- Add Item to Player
        Core.Player.AddItem(source, item.name,item.count, (item.info or nil))
    end
  end
end)

RegisterNetEvent("Dirk:Inventory:Closed", function(id)
  local inv = Core.Inventory.GetById(id)
  inv.ChangeUse(false)
end)

local c = function(t)
  local count = 0 
  for k,v in pairs(t) do 
    count = count + 1
  end
  return count
end

local cleanse = function(t)
  for k,v in pairs(t) do 
    if (v.count > 1 and v.info) or type(v.info) == "string" or (v.info and c(v.info) == 0) then 
      t[k].info = nil
    end
  end
  return t
end

Core.Callback("Dirk:Inventory:Open", function(src,cb,id)
  local tInv = Core.Inventory.GetById(id)
  if not tInv then cb(nil, nil) return false; end
  if tInv.inUse then cb(nil,nil) return false; end  
  tInv.ChangeUse(true)



  local invs = {
    {
      id = "Player",
      label = "My Inventory",
      items = cleanse(Core.Player.Inventory(src)),
    },
    {
      id = tInv.ID,
      label = tInv.Name,
      items = cleanse(tInv.Items),
    },
  }
  cb(invs)
end)

-- TriggerServerEvent("Dirk:Inventory:Transfer", "Player", "ID1", {
--     name = "bread",
--     label = "Bread",
--     count = 2, 
--     info  = {
--       Stale = true,
--     }
-- })


Citizen.CreateThread(Core.Inventory.Load)