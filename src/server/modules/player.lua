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
    local player = Core.Player.Get(p)
    if not player or type(player) ~= "table" then return; end
    if Config.Framework == "es_extended" then
      return player.identifier
    elseif Config.Framework == "qb-core" then
      return player.PlayerData.citizenid
    elseif Config.Framework == "vrp" then
      return vRP.getUserId(p);
    end
  end,

  Name = function(p)
    local p = tonumber(p)
    local ply = Core.Player.Get(p)
    if not ply then return; end
    if Config.Framework == "es_extended" then
      local raw = ply.getName()
      local firstName, lastName = raw:match("(%a+)%s+(.*)")
      return firstName, lastName
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
    if not ply then return; end
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
    if not ply then return; end
    if Config.Framework == "es_extended" then
      local result = MySQL.Sync.fetchAll("SELECT phone_number FROM users WHERE identifier = @identifier", {['@identifier'] = ply.identifier})
      return result[1] or "No Number"
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
      if Core.Player.Get(tonumber(v)) then
        if Core.Player.Id(tonumber(v)) == id then
          return v
        end
      end
    end
    return false
  end,

  Jail = function(id,time, source)
    if Config.JailSystem == "esx_jail" then

      TriggerEvent('esx_jail:sendToJail', id, time * 60, true)
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
    elseif Config.JailSystem == "rcore_prison" then
      exports['rcore_prison']:Jail(id, time, "Bounty Hunter")
    elseif Config.JailSystem == "pickle_prisons" then
      exports["pickle_prisons"]:JailPlayer(id, time, "default")
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
          slot  = (v.slot or nil),
        })
      end
    end
    return ret
  end,

  EditItemMetadata = function(p, slot, new)
    local ply = Core.Player.Get(p)
    if Config.Inventory == "qs-inventory" and Config.NewQSInventory then
      exports['qs-inventory']:SetItemMetadata(p, slot, new)
    elseif Config.Inventory == "ox_inventory" then
      exports['ox_inventory']:SetMetadata(p, slot, new)
    elseif Config.Inventory == "mf-inventory" then
      exports["mf-inventory"]:addInventoryItem(Core.Player.Id(p), i, a, p, 100, md)
    elseif Config.Inventory == "core_inventory" then
      print(' FEATURE NOT SUPPORTED YET')
    else
      --## FALL BACK FOR MOST INVENTORIES
      -- OLD QS
      -- QB-INVENTORY
      -- LJ-INVENTORY
      -- ESX-INVENTORY
      if Config.Framework == "es_extended" then
        ply.addInventoryItem(i,a, md or nil)
      elseif Config.Framework == "qb-core" then
        if ply.Functions.RemoveItem(i,a,slot) then 
          ply.Functions.AddItem(i,a, slot, new)
        end
      end
    end
  end,

  AddItem = function(p,i,a,md)
    local ply = Core.Player.Get(p)
    if Config.Inventory == "qs-inventory" and Config.NewQSInventory then
      exports['qs-inventory']:AddItem(tonumber(p),i,a,false,md)
    elseif Config.Inventory == "ox_inventory" then
      exports['ox_inventory']:AddItem(p, i, a, md, nil, function(success, reason)
        if not success then
          if reason == "invalid_item" then print("You must make sure to add items from this script into your ox_inventory items.lua\nCheck the readme of the script for more details") return false; end
          if reason ~= "invalid_item" then print(reason) print('Some sort of issue with ox_inventory make a ticket on DirkScripts Discord!') return false; end
        end
      end)
    elseif Config.Inventory == "mf-inventory" then
      exports["mf-inventory"]:addInventoryItem(Core.Player.Id(p), i, a, p, 100, md)
    elseif Config.Inventory == "core_inventory" then
      exports['core_inventory']:addItem('primary-'..Core.Player.Id(p), i, a, md)
    else
      --## FALL BACK FOR MOST INVENTORIES
      -- OLD QS
      -- QB-INVENTORY
      -- LJ-INVENTORY
      -- ESX-INVENTORY
      if Config.Framework == "es_extended" then
        ply.addInventoryItem(i,a, md or nil)
      elseif Config.Framework == "qb-core" then
        ply.Functions.AddItem(i,a, nil, md or nil)
        TriggerClientEvent('inventory:client:ItemBox', p, QBCore.Shared.Items[i], "add")
      end
    end
  end,

  RemoveItem = function(p,i,a, md, slot)
    local ply = Core.Player.Get(p)
    if Config.NewQSInventory then
      return exports['qs-inventory']:RemoveItem(p, i, a, slot, md)
    elseif Config.Inventory == 'ox_inventory' then
      return exports['ox_inventory']:RemoveItem(p, i, a, md, slot)
    else
      --## Framework Fallback
      if Config.Framework == "es_extended" then
        ply.removeInventoryItem(i,a)
        return true
      elseif Config.Framework == "qb-core" then
        if ply.Functions.RemoveItem(i,a,slot) then
          TriggerClientEvent('inventory:client:ItemBox', p, QBCore.Shared.Items[i], "remove")
          return true
        end
      elseif Config.Framework == "vrp" then
        vRP.tryGetInventoryItem(ply, i, a)
        return true
      end
    end
    return false
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

  GetGang = function(p)
    local gt = {}
    local ply = Core.Player.Get(tonumber(p))
    if Config.Framework == "qb-core" then
      if not Config.GangSystem then
        local rawGang = ply.PlayerData.gang
        gt.name  = rawGang.name
        gt.label = rawGang.label
        gt.rank  = rawGang.grade.level
        gt.rankL = rawGang.grade.name
      end
    end
    return gt
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

  UpdateInfo = function(p,_type,info)
    local ply = Core.Player.Get(tonumber(p))
    if Config.Framework == "es_extended" then
      if _type == "firstname" then
        local currentFirst, currentLast = Core.Player.Name(p)
        ply.setName(info.." "..currentLast)
      elseif _type == "lastname" then
        local currentFirst, currentLast = Core.Player.Name(p)
        ply.setName(currentFirst.." "..info)
      end
    elseif Config.Framework == "qb-core" then
      if _type == "firstname" or _type == "lastname" or _type == "gender" or _type == "birthdate" or _type == "phone" then
        local charInfo = ply.PlayerData.charinfo
        charInfo[_type] = info
        ply.Functions.SetPlayerData("charinfo", charInfo)
      elseif _type == "accounts" then
        Core.Player.SetMoney(p, _type,info, "ADMIN MENU")
      end
    end
  end,  UpdateInfo = function(p,_type,info)
    local ply = Core.Player.Get(tonumber(p))
    if Config.Framework == "es_extended" then
      if _type == "firstname" then
        local currentFirst, currentLast = Core.Player.Name(p)
        ply.setName(info.." "..currentLast)
      elseif _type == "lastname" then
        local currentFirst, currentLast = Core.Player.Name(p)
        ply.setName(currentFirst.." "..info)
      end
    elseif Config.Framework == "qb-core" then
      if _type == "firstname" or _type == "lastname" or _type == "gender" or _type == "birthdate" or _type == "phone" then
        local charInfo = ply.PlayerData.charinfo
        charInfo[_type] = info
        ply.Functions.SetPlayerData("charinfo", charInfo)
      elseif _type == "accounts" then
        Core.Player.SetMoney(p, _type,info, "ADMIN MENU")
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
    if not ply then return false; end
    if Config.Framework == "es_extended" then
      local ret = {}
      local rawAccounts = ply.getAccounts()
      for k,v in pairs(rawAccounts) do
        ret[v.name] = v.money
      end
      return ret
    elseif Config.Framework == "qb-core" then
      return ply.PlayerData.money
    elseif Config.Framework == "vrp" then
      return {
        cash = vRP.getMoney(ply),
        bank = vRP.getBankMoney(ply)
      }
    end
  end,

  SetMoney = function(p,acc,a)
    local ply = Core.Player.Get(tonumber(p))
    a = tonumber(a)
    if Config.Framework == "es_extended" then
      ply.setAccountMoney(acc,a)
    elseif Config.Framework == "qb-core" then
      ply.Functions.SetMoney(acc,a)
    elseif Config.Framework == "vrp" then
      if acc == "cash" then
        vRP.setMoney(ply,a)
      elseif acc == "bank" then
        vRP.setBankMoney(ply,a)
      end
    end
  end,




  RemoveMoney = function(p,acc,a)
    local ply = Core.Player.Get(tonumber(p))
    if Config.Framework == "es_extended" then
      return ply.removeAccountMoney(acc,a)
    elseif Config.Framework == "qb-core" then
      return ply.Functions.RemoveMoney(acc,a)
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