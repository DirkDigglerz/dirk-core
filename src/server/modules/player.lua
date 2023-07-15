Core.Player = {
  Get = function(s)
    if Config.Framework == "es_extended" then
      return ESX.GetPlayerFromId(s)
    elseif Config.Framework == "qb-core" then
      return QBCore.Functions.GetPlayer(s)
    elseif Config.Framework == "vrp" then 
      return vRP.getUserId(s);
    end
  end,

  Id = function(p)
    if Config.Framework == "es_extended" then
      return ESX.GetPlayerFromId(p).identifier
    elseif Config.Framework == "qb-core" then
      return QBCore.Functions.GetPlayer(p).PlayerData.citizenid
    elseif Config.Framework == "vrp" then 
      return vRP.getUserId(p);
    end
  end,

  Name = function(p)
    local p = tonumber(p)
    local ply = Core.Player.Get(p)
    if Config.Framework == "es_extended" then
      return ply.getName()
    elseif Config.Framework == "qb-core" then
      return ply.PlayerData.charinfo.firstname, ply.PlayerData.charinfo.lastname
    elseif Config.Framework == "vrp" then 
      local identity = vRP.getUserIdentity(Core.Player.Id(p))
      return identity.name, identity.name2
    end
  end,

  DOB = function(p)
    local p = tonumber(p)
    local ply = Core.Player.Get(p)
    if Config.Framework == "es_extended" then
      return "Circa 1923"
    elseif Config.Framework == "qb-core" then
      return ply.PlayerData.charinfo.birthdate
    elseif Config.Framework == "vrp" then

    end
  end,

  PhoneNumber = function(p)
    local p = tonumber(p)
    local ply = Core.Player.Get(p)
    if Config.Framework == "es_extended" then
      return ply.getPhoneNumber()
    elseif Config.Framework == "qb-core" then
      return ply.PlayerData.charinfo.phone
    elseif Config.Framework == "vrp" then
      return vRP.getPhoneDirectory(Core.Player.Id(p))
    end
  end,

  Gender = function(p)
    local p = tonumber(p)
    local ply = Core.Player.Get(p)
    if Config.Framework == "es_extended" then 
      
    elseif Config.Framework == "qb-core" then 
      return ply.PlayerData.charinfo.gender
    end
  end,

  CheckOnline = function(id)
    local plys = GetPlayers()
    for k,v in pairs(plys) do
      if Core.Player.Id(tonumber(v)) == id then
        return v
      end
    end
    return false
  end,

  Jail = function(id,time)
    if Config.JailSystem == "esx_jail" then 
      TriggerEvent('esx_jail:sendToJail', id, time * 60)
    elseif Config.JailSystem == "qb-prison" then
      local OtherPlayer = Core.Player.Get(id)
      if not OtherPlayer then return; end

      local currentDate = os.date("*t")
      if currentDate.day == 31 then
          currentDate.day = 30
      end

      OtherPlayer.Functions.SetMetaData("injail", time)
      OtherPlayer.Functions.SetMetaData("criminalrecord", {
          ["hasRecord"] = true,
          ["date"] = currentDate
      })
      TriggerClientEvent("police:client:SendToJail", OtherPlayer.PlayerData.source, time)
    end
  end,

  Inventory = function(p)
    local ply = Core.Player.Get(tonumber(p))
    local ret = {}
    local inv = {}
    if Config.Framework == "es_extended" then
      inv = ply.getInventory()
    elseif Config.Framework == "qb-core" then
      inv = ply.PlayerData.items
    elseif Config.Framework == "vrp" then
      inv = vRP.getInventory(ply)
    end

    if Config.Inventory == "mf-inventory" then
      inv = exports["mf-inventory"]:getInventory(ply.identifier).items
    end


    for k,v in pairs(inv) do
      if (v.amount and v.amount >= 1) or (v.count and v.count >= 1) then
      table.insert(ret, {
          name  = v.name,
          label = v.label,
          count = (v.amount or v.count),
          info  = (v.info or v.metadata or false),
        })
      end
    end
    return ret
  end,

  AddItem = function(p,i,a,md)
    local ply = Core.Player.Get(p)
    if Config.Inventory == "qb-inventory" or Config.Inventory == "lj-inventory" then
      ply.Functions.AddItem(i, a, false, md)
      TriggerClientEvent('inventory:client:ItemBox', p, QBCore.Shared.Items[i], "add")
    elseif Config.Inventory == "mf-inventory" then
      ply.addInventoryItem(i, a, 100.0, md)
    elseif Config.Inventory == "qs-inventory" then
      if Config.NewQSInventory then 
        exports['qs-inventory']:AddItem(tonumber(p),i,a,false,md)
      else
        TriggerEvent('qs-inventory:addItem', tonumber(p), i, a, false, md)
      end
    
    elseif Config.Inventory == "ox_inventory" then
      exports['ox_inventory']:AddItem(p, i, a, md, nil, function(success, reason)
        if not success then
          if reason == "invalid_item" then print("You must make sure to add items from this script into your ox_inventory items.lua\nCheck the readme of the script for more details") return false; end
          if reason ~= "invalid_item" then print(reason) print('Some sort of issue with ox_inventory make a ticket on DirkScripts Discord!') return false; end
        end
      end)
    else
      if Config.Framework == "es_extended" then
        ply.addInventoryItem(i,a)
      elseif Config.Framework == "qb-core" then
        ply.Functions.AddItem(i,a, md or nil)
        TriggerClientEvent('inventory:client:ItemBox', p, QBCore.Shared.Items[i], "add")
      end
    end

  end,

  RemoveItem = function(p,i,a)
    local ply = Core.Player.Get(p)
    if Config.NewQSInventory then 
      exports['qs-inventory']:RemoveItem(p, i, a)
      return true
    elseif Config.Framework == "es_extended" then
      ply.removeInventoryItem(i,a)
      return true
    elseif Config.Framework == "qb-core" then
      ply.Functions.RemoveItem(i,a)
      TriggerClientEvent('inventory:client:ItemBox', p, QBCore.Shared.Items[i], "remove")
      return true
    elseif Config.Framework == "vrp" then
      vRP.tryGetInventoryItem(ply, i, a)
      return true
    end
  end,

  HasItem = function(p,i,a,md)
    local inv = Core.Player.Inventory(p)
    for k,v in pairs(inv) do
      if v.name == i and v.count > 0 then
        if not md and v.count >= a then
          return true
        elseif md and v.count >= a and type(v.info) == "table" then
          if Core.Inventory.CheckMatch(v.info, md) then return true; end
        end
      end
    end
    return false
  end,

  GetJob = function(p)
    local ply = Core.Player.Get(tonumber(p))
    if not ply then return {}; end
    local jt = {}
    if Config.Framework == "es_extended" then
      jt.name  =  ply.job.name
      jt.label =  ply.job.label
      jt.rank  =  ply.job.grade
      jt.rName  = ply.job.grade_name
      jt.rLabel = ply.job.grade_label
      jt.duty   = true
      jt.isBoss = false
      jt.isCop =  Config.PoliceJobs[ply.job.name]
    elseif Config.Framework == "qb-core" then
      jt.name  = ply.PlayerData.job.name
      jt.label = ply.PlayerData.job.label
      jt.rank  = ply.PlayerData.job.grade.level
      jt.rLabel = ply.PlayerData.job.grade.label
      jt.duty  = ply.PlayerData.job.onduty
      jt.isBoss = ply.PlayerData.job.isboss
      jt.isCop = Config.PoliceJobs[ply.PlayerData.job.name]
    elseif Config.Framework == "vrp" then
      return vRP.getUserGroupByType(ply, "job")
    end
    return jt
  end,

  SetJob = function(p,j,r)
    local ply = Core.Player.Get(tonumber(p))
    if Config.Framework == "es_extended" then
      ply.setJob(j,r)
    elseif Config.Framework == "qb-core" then
      ply.Functions.SetJob(j,r)
    elseif Config.Framework == "vrp" then 
      vRP.addUserGroup(ply, j)
    end
  end,

  UpdateInfo = function(p,type,info)
    local ply = Core.Player.Get(tonumber(p))
    if Config.Framework == "es_extended" then
      
    elseif Config.Framework == "qb-core" then
      if type == "firstname" or type == "lastname" or type == "gender" or type == "birthdate" or type == "phone" then
        local charInfo = ply.PlayerData.charinfo
        charInfo[type] = info
        ply.Functions.SetPlayerData("charinfo", charInfo)
      elseif type == "accounts" then 
        for k,v in pairs(info) do 
          Core.Player.SetMoney(k,v, "ADMIN MENU")
        end
      end
    end
  end,

  SetGang = function(p,g,r)
    local ply = Core.Player.Get(tonumber(p))
    if Config.Framework == "es_extended" then
      print('ESX does not have a standardised gang system please insert your own code here')
    elseif Config.Framework == "qb-core" then
      ply.Functions.SetGang(g,r)
    elseif Config.Framework == "vrp" then 
      vRP.addUserGroup(ply, g)
    end
  end,

  Revive = function(p)
    if Config.Framework == "qb-core" then
      TriggerClientEvent('hospital:client:Revive', tonumber(p))
    elseif Config.Framework == "es_extended" then
      TriggerClientEvent('esx_ambulancejob:revive', tonumber(p)) -- IS THIS RIGHT?
    elseif Config.Framework == "vrp" then 
      vRPclient.varyHealth(Core.Player.Get(tonumber(p)), {100})
    end
  end,

  --## MONEY FUNCTIONS

  GetAccounts = function(p)
    local ply = Core.Player.Get(tonumber(p))
    if Config.Framework == "es_extended" then
      return ply.getAccounts()
    elseif Config.Framework == "qb-core" then
      return ply.PlayerData.money
    elseif Config.Framework == "vrp" then
      return {
        cash = vRP.getMoney(ply),
        bank = vRP.getBankMoney(ply)
      }
    end
  end,

  RemoveMoney = function(p,acc,a)
    local ply = Core.Player.Get(tonumber(p))
    if Config.Framework == "es_extended" then
      ply.removeAccountMoney(acc,a)
    elseif Config.Framework == "qb-core" then
      ply.Functions.RemoveMoney(acc,a)
    elseif Config.Framework == "vrp" then 
      if acc == "cash" then
        vRP.tryPayment(ply,a)
      elseif acc == "bank" then
        vRP.tryBankPayment(ply,a)
      end
    end
  end,

  AddMoney = function(p,acc,a)
    local ply = Core.Player.Get(tonumber(p))
    if Config.Framework == "es_extended" then
      local accs = ply.getAccounts()
      local exists = false
      for k,v in pairs(accs) do
        if v.name == acc then
          exists = true
          break
        end
      end
      ply.addAccountMoney(acc,a)
    elseif Config.Framework == "qb-core" then
      ply.Functions.AddMoney(acc,a)
    elseif Config.Framework == "vrp" then 
      if acc == "cash" then
        vRP.giveMoney(ply,a)
      elseif acc == "bank" then
        vRP.giveBankMoney(ply,a)
      end
    end
  end,

  HasMoney = function(p,a)
    local ply = Core.Player.Get(tonumber(p))
    if Config.Framework == "es_extended" then
      local has, account
      for k,v in pairs(Config.FrameworkAccounts) do
        local tryAcc = ply.getAccount(v)
        if tryAcc and tryAcc.money >= a then
          has = true
          account = v
          return v
        end
      end
    elseif Config.Framework == "qb-core" then
      local has, account
      for k,v in pairs(Config.FrameworkAccounts) do
        if ply.Functions.GetMoney(v) >= a then
          return v
        end
      end
    elseif Config.Framework == "vrp" then
      if vRP.getMoney(ply) >= a then
        return "cash"
      elseif vRP.getBankMoney(ply) >= a then
        return "bank"
      end
    end
    return false
  end,

  HasMoneyInAccount = function(p,acc,a)
    local ply = Core.Player.Get(tonumber(p))
    if Config.Framework == "es_extended" then
      if ply.getAccount(acc).money >= a then
        return true
      end
    elseif Config.Framework == "qb-core" then
      if ply.PlayerData.money[acc] and (ply.PlayerData.money[acc] >= a) then
        return true
      end
    elseif Config.Framework == "vrp" then 
      if acc == "cash" then
        if vRP.getMoney(ply) >= a then
          return true
        end
      elseif acc == "bank" then
        if vRP.getBankMoney(ply) >= a then
          return true
        end
      end
    end
    return false
  end,
}

