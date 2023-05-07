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
    print('Dirk-Core has detected that you are running qb-core as your framework')
  elseif esx ~= "missing" and esx ~= "unkown" then
    print('Dirk-Core has detected that you are running es_extended as your framework')
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
      print('Dirk-Core has detected you are running ', k,' as your inventory')
    end
  end
  for k,v in pairs(timesystems) do
    local resState = GetResourceState(k)
    if resState ~= "missing" and resState ~= "unknown" then
      Config.TimeSystem = k
      print('Dirk-Core has detected you are running ', k,' as your time system ')
    end
  end

  local ox = GetResourceState('ox_target')
  if ox ~= "missing" and ox ~= "unknown" then
    Config.TargetSystem = "ox_target"
    print('Dirk-Core has detected you are running ', Config.TargetSystem,' as your target system')
  else
    for k,v in pairs(targetsystems) do
      local resState = GetResourceState(k)
      print('resState', resState)
      if resState ~= "missing" and resState ~= "unknown" then
        Config.TargetSystem = k
        print('Dirk-Core has detected you are running ', k,' as your target system')
      end
    end
  end
end)


if Config.UsingESX then
  TriggerEvent("esx:getSharedObject", function(obj) ESX = obj; end)
  --ESX = exports["es_extended"]:getSharedObject() -- Uncomment if spamming errors
elseif Config.UsingQBCore then
  QBCore = exports['qb-core']:GetCoreObject()
  RegisterNetEvent('QBCore:Client:UpdateObject', function() QBCore = exports['qb-core']:GetCoreObject(); end)
end

