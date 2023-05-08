-- Inventory resource name = Image path
local inventories = {
  ['qb-inventory'] = "qb-inventory/html/images/",
  ['qs-inventory'] = "qs-inventory/html/images/",
  ['mf-inventory'] = "mf-inventory/nui/items/",
  ['ox_inventory'] = "ox_inventory/web/images/",
}



local progressbars = {"progressbar","ox_lib"}
local targetsystems = {'qtarget', 'qb-target', 'ox_target'}
local timesystems = {'vSync', 'cd_easytime', 'qb-weathersync'}
local jailSystems = {'esx_jail', 'qb-prison'}

Citizen.CreateThread(function()
  local qb = GetResourceState('qb-core') -- If you cleverly :rollseyes: changed the name of qb-core then change this to the name of "your" framework
  local esx = GetResourceState('es_extended')

--[[DONT TOUCH BELOW UNLESS YOU KNOW WHAT YOU ARE DOING!!!]]

  local fw = ""
  Config.UsingQBCore = false -- DONT TOUCH. WILL AUTOMATICALLY DETECT!
  Config.UsingESX = false -- DONT TOUCH. WILL AUTOMATICALLY DETECT!
  local Count = {jail = 0, target = 0, time = 0, inventory = 0, progressbar = 0}

  if qb ~= "missing" and qb ~= "unknown" then
    Config.UsingQBCore = true
    fw = 'QB-CORE'
    QBCore = exports['qb-core']:GetCoreObject()
    RegisterNetEvent('QBCore:Client:UpdateObject', function() QBCore = exports['qb-core']:GetCoreObject(); end)
  elseif esx ~= "missing" and esx ~= "unkown" then
    Config.UsingESX = true
    fw = "ESX"
    TriggerEvent("esx:getSharedObject", function(obj) ESX = obj; end)
  else
    print('Dirk-Core has not detected a framework please create a ticket')
  end

  for k,v in pairs(jailSystems) do
    local resState = GetResourceState(v)
    if resState ~= "missing" and resState ~= "unknown" then
      Config.JailSystem = k
      Count.jail = Count.jail + 1
    end
  end

  for k,v in pairs(inventories) do
    local resState = GetResourceState(k)
    if resState ~= "missing" and resState ~= "unknown" then
      Config.Inventory = k
      Config.ItemIconsDir = v
      Count.inventory = Count.inventory + 1
    end
  end
  for _,v in pairs(timesystems) do
    local resState = GetResourceState(v)
    if resState ~= "missing" and resState ~= "unknown" then
      Config.TimeSystem = v
      Count.time = Count.time + 1
    end
  end

  for _,v in pairs(progressbars) do
    local resState = GetResourceState(v)
    if resState ~= "missing" and resState ~= "unknown" then
      Config.ProgressBar = v
      Count.time = Count.progressbar + 1
    end
  end

  local ox = GetResourceState('ox_target')
  if ox ~= "missing" and ox ~= "unknown" then
    Config.TargetSystem = "ox_target"
  else
    for _,v in pairs(targetsystems) do
      local resState = GetResourceState(v)
      if resState ~= "missing" and resState ~= "unknown" then
        Config.TargetSystem = v
        Count.target = Count.target + 1
      end
    end
  end

  for k,v in pairs(Count) do
    if v == 0 then
      print('^1Dirk-Core^7\nWe have not detected a '..k..' system please create a ticket')
    elseif v > 1 then
      print('^1Dirk-Core^7\nWe have detected more than one '..k..' system please create a ticket')
    end
  end

  print(string.format('^2Dirk-Core^7\nWe have detected you are using the following:\nFramework: %s\nInventory: %s\nTime Sync: %s\nTarget System: %s', fw, Config.Inventory, Config.TimeSystem,Config.TargetSystem))
end)