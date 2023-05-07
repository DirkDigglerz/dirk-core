  --## AUTOMATICALLY SET VARIABLES
  --## TIME AND WEATHER SYNC
  Config.TimeSystem = "qb-weathersync" --## vSync or cd_easytime or qb-weathersync
  --## INVENTORY SYSTEM
  Config.Inventory         = "ox_inventory" --## "qb-inventory", "mf-inventory", "qs-inventory", "ox_inventory"
  Config.ItemIconsDir      = "ox_inventory/web/images/" --## Directory for the icons you use for your inventory.
  --## TARGET
  Config.TargetSystem = "ox_target" --## qb-target, qtarget, ox_target, dirk-prompts,
  --## FRAMEWORK OPTION
  Config.UsingQBCore = true
  Config.UsingESX    = false

local inventories = {
  ['qb-inventory'] = "qb-inventory/html/images/",
  ['qs-inventory'] = "qs-inventory/html/images/",
  ['mf-inventory'] = "mf-inventory/nui/items/",
  ['ox_inventory'] = "ox_inventory/web/images/",
}

local targetsystems = {
  ['qtarget'] = true,
  ['qb-target'] = true,
  ['ox_target'] = true,
}

local timesystems = {
  ['vSync'] = true,
  ['cd_easytime'] = true,
  ['qb-weathersync'] = true,
}

Citizen.CreateThread(function()
  local qb = GetResourceState('qb-core')
  local esx = GetResourceState('es_extended')
  if qb ~= "missing" and qb ~= "unknown" then
    Config.UsingQBCore = true
    Config.UsingESX = false
  elseif esx ~= "missing" and esx ~= "unkown" then
    Config.UsingQBCore = false
    Config.UsingESX = true
  else
    print('Dirk-Core has not detected a framework please create a ticket')
  end

  for k,v in pairs(inventories) do
    local resState = GetResourceState(k)
    if resState ~= "missing" and resState ~= "unknown" then
      Config.Inventory = k
      Config.ItemIconsDir = v
    end
  end
  for k,v in pairs(timesystems) do
    local resState = GetResourceState(k)
    if resState ~= "missing" and resState ~= "unknown" then
      Config.TimeSystem = k
    end
  end

  local ox = GetResourceState('ox_target')
  if ox ~= "missing" and ox ~= "unknown" then
    Config.TargetSystem = "ox_target"
  else
    for k,v in pairs(targetsystems) do
      local resState = GetResourceState(k)
      print('resState', resState)
      if resState ~= "missing" and resState ~= "unknown" then
        Config.TargetSystem = k
      end
    end
  end
  local fw = ''
  if Config.UsingESX == false and Config.UsingQBCore == true then 
    fw = 'QB-CORE'
  elseif Config.UsingESX == true and Config.UsingQBCore == false then 
    fw = "ESX"
  end
  print(string.format('^2Dirk-Core^7\nWe have detected you are using the following:\nFramework: %s\nInventory: %s\nTime Sync: %s\nTarget System: %s', fw, Config.Inventory, Config.TimeSystem,Config.TargetSystem))
end)


if Config.UsingESX then
  TriggerEvent("esx:getSharedObject", function(obj) ESX = obj; end)
  --ESX = exports["es_extended"]:getSharedObject() -- Uncomment if spamming errors
elseif Config.UsingQBCore then
  QBCore = exports['qb-core']:GetCoreObject()
  RegisterNetEvent('QBCore:Client:UpdateObject', function() QBCore = exports['qb-core']:GetCoreObject(); end)
end

