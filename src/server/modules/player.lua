Core.Player = {
  Get = function(s)
    if Config.UsingESX then 
      return ESX.GetPlayerFromId(s)
    elseif Config.UsingQBCore then 
      return QBCore.Functions.GetPlayer(s)
    end
  end,

  Id = function(p)
    if Config.UsingESX then 
      return ESX.GetPlayerFromId(source).identifier
    elseif Config.UsingQBCore then 
      return QBCore.Functions.GetPlayer(p).PlayerData.citizenid
    end
  end,

  Name = function(p)
    local p = tonumber(p)
    local ply = Core.Player.Get(p)
    if Config.UsingESX then   
      return ply.getName()
    elseif Config.UsingQBCore then 
      return ply.PlayerData.charinfo.firstname.." "..ply.PlayerData.charinfo.lastname
    end
  end,

  DOB = function(p)
    local p = tonumber(p)
    local ply = Core.Player.Get(p)
    if Config.UsingESX then 
      return "Circa 1923"
    elseif Config.UsingQBCore then 
      return ply.PlayerData.charinfo.birthdate
    end
  end,

  Inventory = function(p)
    local ply = Core.Player.Get(tonumber(p))
    local ret = {}
    if Config.UsingESX then 

    elseif Config.UsingQBCore then 
      for k,v in pairs(ply.PlayerData.items) do 
        if (v.amount and v.amount >= 1) or (v.count and v.count >= 1) then 
         table.insert(ret, {
            name  = v.name, 
            label = v.label,
            count = (v.amount or v.count),
            info  = (v.info or false),
          })
        end
      end
      return ret
    end
    return ret
  end,

  AddItem = function(p,i,a,md)
    local ply = Core.Player.Get(p)
    if not md then 
      if Config.UsingESX then 
        ply.addInventoryItem(i,a)
      elseif Config.UsingQBCore then 
        ply.Functions.AddItem(i,a)
        TriggerClientEvent('inventory:client:ItemBox', p, QBCore.Shared.Items[i], "add")
      end
    else
      if Config.Inventory == "qb-inventory" then 
        ply.Functions.AddItem(i, a, false, md)
        TriggerClientEvent('inventory:client:ItemBox', p, QBCore.Shared.Items[i], "add")
      elseif Config.Inventory == "mf-inventory" then 
        ply.addInventoryItem(i, a, 100.0, md)
      elseif Config.Inventory == "qs-inventory" then 
        TriggerEvent('qs-inventory:addItem', tonumber(p), i, a, false, md)
      elseif Config.Inventory == "ox-inventory" then 
        exports['ox_inventory']:AddItem(p, i, a, md, nil, function(success, reason)
          if not success then 
            print(reason)
            print('Some sort of issue with ox_inventory make a ticket on DirkScripts Discord!')
          end
        end)
      end      
    end
  end,

  RemoveItem = function(p,i,a)
    local ply = Core.Player.Get(p)
    if Config.UsingESX then 
      ply.removeInventoryItem(i,a)
      return true
    elseif Config.UsingQBCore then 
      ply.Functions.RemoveItem(i,a)
      TriggerClientEvent('inventory:client:ItemBox', p, QBCore.Shared.Items[i], "remove")
      return true
    end
  end,

  HasItem = function(p, i,a)
    local ply = Core.Player.Get(p)
    if Config.UsingESX then 
      local item = ply.getInventoryItem(i)
      if item and item.count >= a then 
        return true
      end
    elseif Config.UsingQBCore then 
      local item = ply.Functions.GetItemByName(i)
      if item and item.amount >= tonumber(a) then 
        return true
      end
    end
    return false
  end,

  GetPlayerJob = function(p)
    local ply = Core.Player.Get(tonumber(p))
    if not ply then return {}; end
    local jt = {}

    if Config.UsingQBCore then 
      jt.grade = ply.PlayerData.job.grade.level
      jt.name  = ply.PlayerData.job.name
      return jt
    elseif Config.UsingESX then 
      jt.grade = ply.job.grade
      jt.name  = ply.job.name
      return jt
    end
    return {}
  end,


  RemoveMoney = function(p,acc,a)
    local ply = Core.Player.Get(tonumber(p))
    if Config.UsingESX then 
      ply.removeAccountMoney(acc,a)
    elseif Config.UsingQBCore then 
      ply.Functions.RemoveMoney(acc,a)
    end
  end,

  AddMoney = function(p,acc,a)
    if Config.UsingESX then 
      local ply = ESX.GetPlayerFromId(p)
      local accs = ply.getAccounts()
      local exists = false
      for k,v in pairs(accs) do
        if v.name == acc then
          exists = true
          break
        end
      end
      ply.addAccountMoney(acc,a)
    elseif Config.UsingQBCore then 
      local ply = QBCore.Functions.GetPlayer(p)
      ply.Functions.AddMoney(acc,a)
    end
  end,

  HasMoney = function(p,a)
    local ply = Core.Player.Get(tonumber(p))
    if Config.UsingESX then
      local has, account 
      for k,v in pairs(Config.FrameworkAccounts) do 
        local tryAcc = ply.getAccount(v)
        if tryAcc and tryAcc.money >= a then 
          has = true 
          account = v
          return v
        end
      end
    elseif Config.UsingQBCore then 
      local has, account
      for k,v in pairs(Config.FrameworkAccounts) do 
        if ply.Functions.GetMoney(v) >= a then 
          return v 
        end
      end
    end
    return false
  end,

  HasMoneyInAccount = function(p,acc,a)
    local ply = Core.Player.Get(tonumber(p))
    if Config.UsingESX then 
      
    elseif Config.UsingQBCore then 
      if ply.PlayerData.money[acc] and (ply.PlayerData.money[acc] >= a) then 
        return true
      end
    end
    return false
  end,
}

Core.Callback("Dirk-Core:HasItem", function(src,cb,item,a)
  cb(Core.Player.HasItem(src, item,a))
end)