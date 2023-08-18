
local glm = require 'glm'

Core.Polygon = {
  IsPointInside = function(point, polygon)
    for k,v in pairs(polygon) do 
      polygon[k] = vector3(v.x,v.y, point.z) 
    end
    local polygon = glm.polygon.new(polygon)
    return polygon:contains(point)
  end,

  getMinMax = function(points)
    local minX, maxX = nil,nil
    local minY, maxY = nil,nil
    local minZ, maxZ = nil,nil

    for k,v in ipairs(points) do
      if not minX or v.x < minX then minX = v.x; end
      if not minY or v.y < minY then minY = v.y; end
      if not minZ or v.z < minZ then minZ = v.z; end

      if not maxX or v.x > maxX then maxX = v.x; end
      if not maxY or v.y > maxY then maxY = v.y; end
      if not maxZ or v.z > maxZ then maxZ = v.z; end
    end

    return minX, maxX, minY, maxY, minZ, maxZ
  end,

  plotPolygon = function(points, pointDist, minDistance)
    local xMin,xMax,yMin,yMax,zMin,zMax = Core.Polygon.getMinMax(points)
    local polygon = glm.polygon.new(points)

    local z = zMin + (zMax - zMin)
    local height = (zMax - zMin) * 2
    local step = pointDist or 1

    local plot = {}

    for x=xMin,xMax,step do
      for y=yMin,yMax,step do
        local point = vector3(x, y, z)

        if polygon:contains(point, height) then
          table.insert(plot, point)
        end
      end
    end

    if minDistance then
      for j=1,#plot,1 do
        if plot[j] then
          for i=#plot,1,-1 do
            if j ~= i then
              local dist = #(plot[i] - plot[j])

              if dist < minDistance then
                table.remove(plot, i)

              end
            end
          end
        end
      end
    end

    return plot
  end,
  
  DrawWall = function(pos1,pos2,height)
    local r,g,b,a = 0,255,0,54
    local topLeft     = vector3(pos1.x, pos1.y, pos1.z + height)
    local bottomLeft  = vector3(pos1.x,pos1.y,pos1.z)
    local topRight    = vector3(pos2.x,pos2.y,pos2.z + height)
    local bottomRight = vector3(pos2.x,pos2.y,pos2.z)
    DrawPoly(bottomLeft,topLeft,bottomRight,r,g,b,a)
    DrawPoly(topLeft,topRight,bottomRight,r,g,b,a)
    DrawPoly(bottomRight,topRight,topLeft,r,g,b,a)
    DrawPoly(bottomRight,topLeft,bottomLeft,r,g,b,a)
  end,

  newPolygon = function()
    local polygon = {}
    local height  = 5.0
    while true do 
      local wait_time = 0
      local ply = PlayerPedId() 
      for k,v in pairs(polygon) do 
        local firstPoint, secondPoint
        if k == 1 then 
          firstPoint = polygon[#polygon]
          secondPoint = polygon[k]
        else
          firstPoint = polygon[k - 1]
          secondPoint = polygon[k]
        end

        Core.Polygon.DrawWall(firstPoint, secondPoint, height)
        DrawLine(firstPoint.x, firstPoint.y, i, secondPoint.x, secondPoint.y, i, 255, 0, 0, 255)
      end

      local hit, testCoords, entityHit = Core.UI.ScreenToWorld()
      if (testCoords ~= vector3(0,0,0) and entityHit ~= ply) then
        endCoords = testCoords 
        DrawSphere(endCoords.x,endCoords.y,endCoords.z, 0.2, 255,0,0, 0.7)
      end

     
      Core.UI.AdvancedHelpNotif("polygonPlotter", {
        {
          label = "Add Point",
          key   = "g"
        },
        {
          label = "Remove Last Point",
          key   = "h"
        },
        {
          label = "Finish Polygon",
          key   = "x"
        },
        {
          label = "Increase Height", 
          key   = "⬆️"
        },
        {
          label = "Decrease Height", 
          key   = "⬇️"
        },
        {
          label = "Cancel Polygon",
          key   = "q"
        }
      })
      DisableControlAction(0,47)
      DisableControlAction(0,74)
      DisableControlAction(0,105)
      DisableControlAction(0,172)
      DisableControlAction(0,173)
      DisableControlAction(0,85)

      if IsDisabledControlJustPressed(0, 47) then 
        polygon[#polygon + 1] = endCoords
      elseif IsDisabledControlJustPressed(0, 74) then
        polygon[#polygon] = nil
      elseif IsDisabledControlJustPressed(0, 105) then
        return polygon, height
      elseif IsDisabledControlPressed(0, 172) then
        height = height + 0.05
      elseif IsDisabledControlPressed(0, 173) then
        height = height - 0.05
      elseif IsDisabledControlJustPressed(0, 85) then
        return false
      end


      Wait(wait_time)
    end
  end, 
}

RegisterCommand("testPoly", function(source,arg)
  local polygon = Core.Polygon.newPolygon()
  print(json.encode(polygon))
end)



