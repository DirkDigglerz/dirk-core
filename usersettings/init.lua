function string.insert(str1, str2, pos)
    return str1:sub(1,pos)..str2..str1:sub(pos+1)
end

local SupportedResources = {
  Inventory = {
    ['qb-inventory'] = "qb-inventory/html/images/",
    ['lj-inventory'] = "lj-inventory/html/images/",
    ['qs-inventory'] = "qs-inventory/html/images/",
    ['mf-inventory'] = "mf-inventory/nui/items/",
    ['ox_inventory'] = "ox_inventory/web/images/"
  },
  TargetSystem   = {'qtarget', 'qb-target', 'ox_target'},
  TimeSystem     = {'vSync', 'cd_easytime', 'qb-weathersync'},
  JailSystem     = {'esx_jail', 'qb-prison'},
  ProgressBar    = {'progressbar', 'ox_lib'},
  Framework      = {'es_extended', 'qb-core'},
  KeySystem      = {'qb-vehiclekeys', 'cd_garage'},
  DispatchSystem = {'ps-dispatch', 'cd_dispatch'},
  PhoneSystem    = {'qs-smartphone', 'gks_phone', 'lb-phone', 'nwpd', 'qb-phone'},
}

local FoundResources = {}
Citizen.CreateThread(function()
  for type,resources in pairs(SupportedResources) do 
    for index,resource in pairs(resources) do 
      if type == "Inventory" then 
        if Config.AlternativeResourceNames[type][index] then 
          print("^2Dirk-Core^7 | You are using ^5"..Config.AlternativeResourceNames[type][index].."^7 as an alternative name for ^3"..index.."^7")
          SupportedResources[type][Config.AlternativeResourceNames[type][index]] = resource
          SupportedResources[type][index] = nil
        end
      else
        if Config.AlternativeResourceNames[type][resource] then 
          print("^2Dirk-Core^7 | You are using ^5"..Config.AlternativeResourceNames[type][resource].."^7 as an alternative name for ^3"..SupportedResources[type][index].."^7")
          SupportedResources[type][index] = Config.AlternativeResourceNames[type][resource]
        end  
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
    elseif type == "Inventory" then
      for resource,itemDir in pairs(resources) do 
        local resState = GetResourceState(resource)
        if resState ~= "missing" and resState ~= "unknown" then
          Config[type] = resource 
          Config.ItemsIconsDir = itemDir
          FoundResources[type] = resource  
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
      RegisterNetEvent('QBCore:Client:UpdateObject', function() QBCore = exports['qb-core']:GetCoreObject(); end)
    end
  end
end)
