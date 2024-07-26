function string.insert(str1, str2, pos)
  return str1:sub(1,pos)..str2..str1:sub(pos+1)
end

local SupportedResources = {
Inventory = {
  ['qb-inventory']   = "qb-inventory/html/images/",
  ['lj-inventory']   = "lj-inventory/html/images/",
  ['qs-inventory']   = "qs-inventory/html/images/",
  ['ps-inventory']   = "ps-inventory/html/images/",
  ['mf-inventory']   = "mf-inventory/nui/items/",
  ['ox_inventory']   = "ox_inventory/web/images/",
  ['core_inventory'] = "ox_inventory/web/images/",
},
TargetSystem   = {'qtarget', 'qb-target', 'ox_target'},
TimeSystem     = {'vSync', 'cd_easytime', 'qb-weathersync'},
JailSystem     = {'esx_jail', 'qb-prison', 'rcore_prison', 'pickle_prisons'},
ProgressBar    = {'progressbar', 'ox_lib', 'rprogress'},
Framework      = {'vrp','es_extended', 'qb-core'},
KeySystem      = {'qb-vehiclekeys', 'cd_garage', 'okokGarage', 'qs-vehiclekeys'},
DispatchSystem = {'ps-dispatch', 'cd_dispatch', 'qs-dispatch'},
PhoneSystem    = {'qs-smartphone', 'gksphone', 'lb-phone', 'npwd', 'qb-phone'},
FuelSystem     = {'ox_fuel', 'ps-fuel', 'cdn-fuel', 'LegacyFuel', 'x-fuel'},
}

local datatype = type

local FoundResources = {}
Citizen.CreateThread(function()
for type,resources in pairs(SupportedResources) do 
  for index,resource in pairs(resources) do 
    local altName = Config.AlternativeResourceNames[type][(type == "Inventory" and index or resource)]
    if altName and datatype(altName) == "string" then 
      if type == "Inventory" then 
        SupportedResources[type][altName] = resource
        SupportedResources[type][index] = nil
      else
        SupportedResources[type][index] = altName
      end
      print("^2Dirk-Core^7 | You are using ^5"..altName.."^7 as an alternative name for ^3"..(type == "Inventory" and index or resource).."^7")
    elseif datatype(altName) == "boolean" and altName ~= false then

      print('^2Dirk-Core^7 | ^1 You have not followed the instructions for the alternative resource names for the ^3'..type..'^1 section of dirk-cores config.lua.\n^1Please check the config.lua file and dont change them unless you have renamed this resource.^7')
    end
  end
end

for type,resources in pairs(SupportedResources) do 
  if type == "TargetSystem" then 
    local ox_target = GetResourceState('ox_target')
    if ox_target ~= "missing" and ox_target ~= "unknown" then
      Config[type] = 'ox_target'
      FoundResources[type] = 'ox_target'
    else 
      for index,resource in pairs(resources) do 
        local resState = GetResourceState(resource)
        if resState ~= "missing" and resState ~= "unknown" then
          Config[type] = resource
          FoundResources[type] = resource
        end
      end 
    end
  elseif type == "ProgressBar" then
    local ox_lib = GetResourceState('ox_lib')
    if ox_lib ~= "missing" and ox_lib ~= "unknown" then
      Config[type] = 'ox_lib'
      FoundResources[type] = 'ox_lib'
    else 
      for index,resource in pairs(resources) do 
        local resState = GetResourceState(resource)
        if resState ~= "missing" and resState ~= "unknown" then
          Config[type] = resource
          FoundResources[type] = resource
        end
      end 
    end
  elseif type == "Inventory" then
    local ox_inventory = GetResourceState('ox_inventory')
    if ox_inventory ~= "missing" and ox_inventory ~= "unknown" then
      Config[type]             = 'ox_inventory'
      Config.ItemsIconsDir     = "ox_inventory/web/images/"
      FoundResources[type]     = 'ox_inventory'
    else 
      for resource,itemDir in pairs(resources) do 
        local resState = GetResourceState(resource)
        if resState ~= "missing" and resState ~= "unknown" then
          Config[type]         = resource 
          Config.ItemsIconsDir = itemDir
          FoundResources[type] = resource  
        end        
      end
    end
  else
    for index,resource in pairs(resources) do 
      local resState = GetResourceState(resource)
      if resState ~= "missing" and resState ~= "unknown" then
        Config[type] = resource
        FoundResources[type] = resource
      end
    end
  end
end

for type,_ in pairs(SupportedResources) do 
  if FoundResources[type] then 
    print("^2Dirk-Core^7 | Found ^5"..FoundResources[type].."^7 for ^3"..type.."^7")
  else 
    print("^2Dirk-Core^7 | Found ^8NOTHING^7 for ^3"..type.."^7")
  end
end

if FoundResources.Framework then 
  if Config.Framework == "es_extended" then 
    if Config.ESXGetObjectEvent then 
      TriggerEvent("esx:getSharedObject", function(obj) ESX = obj; end)
    else 
      ESX = exports['es_extended']:getSharedObject()
    end
  elseif Config.Framework == "qb-core" then 
    QBCore = exports['qb-core']:GetCoreObject()
    Core.Shared = QBCore.Shared
    RegisterNetEvent('QBCore:Client:UpdateObject', function() 
      QBCore = exports['qb-core']:GetCoreObject();
    end)
  elseif Config.Framework == "vrp" then 
    local serverSide = IsDuplicityVersion()
    Proxy  = module("vrp", "lib/Proxy")
    Tunnel = module("vrp","lib/Tunnel")
    vRP = Proxy.getInterface("vRP")
    if serverSide then 
      vRPclient = Tunnel.getInterface("vRP")
    end
  end
end
Core.DataLoaded = true

end)

getCore = function()
return Core, Config
end
