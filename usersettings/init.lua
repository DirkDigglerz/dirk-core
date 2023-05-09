-- Inventory resource name = Image path
local inventories = {
  ['qb-inventory'] = "qb-inventory/html/images/",
  ['qs-inventory'] = "qs-inventory/html/images/",
  ['mf-inventory'] = "mf-inventory/nui/items/",
  ['ox_inventory'] = "ox_inventory/web/images/",
}


local SupportedResources = {
  Inventory = {
    ['qb-inventory'] = "qb-inventory/html/images/",
    ['qs-inventory'] = "qs-inventory/html/images/",
    ['mf-inventory'] = "mf-inventory/nui/items/",
    ['ox_inventory'] = "ox_inventory/web/images/"
  },
  TargetSystem = {'qtarget', 'qb-target', 'ox_target'},
  TimeSystem = {'vSync', 'cd_easytime', 'qb-weathersync'},
  JailSystem = {'esx_jail', 'qb-prison'},
  ProgressBar = {'progressbar', 'ox_lib'},
  Framework   = {'es_extended', 'qb-core'},
}

local FoundResources = {}

Citizen.CreateThread(function()
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

  for type,resource in pairs(FoundResources) do 
    print("^2Dirk-Core^7 | Found ^5"..resource.."^7 for ^3"..type.."^7")
  end


end)