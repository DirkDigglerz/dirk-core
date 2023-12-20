local glm = require 'glm'
local randomInRange = function(min, max)
  return min + math.random() * (max - min)
end
Core.Zones = {
  GetRandomPoint = function(points)
    local minX, maxX, minY, maxY, minZ, maxZ = Core.Zones.getMinMax(points)
    -- Find the minimum and maximum values for x and y coordinates
    for i = 1, #points do
      local point = points[i]
      minX = math.min(minX, point.x)
      maxX = math.max(maxX, point.x)
      minY = math.min(minY, point.y)
      maxY = math.max(maxY, point.y)
    end

    -- Generate a random point until it falls within the polygon
    while true do
      local randomPoint = vector3(
        randomInRange(minX, maxX),
        randomInRange(minY, maxY),
        randomInRange(minZ, maxZ)
      )

      -- Check if the random point is within the polygon
      if Core.Zones.IsPointInPolygon(randomPoint, points) then
        return randomPoint
      end
    end
  end,

  getPolygonCenter = function(polygon)
    local center = vector3(0,0,0)
    for _,v in pairs(polygon) do 
      center = center + v
    end
    center = center / #polygon
    return center
  end,
 
  IsPointInPolygon = function(point, polygon)
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
    local xMin,xMax,yMin,yMax,zMin,zMax = Core.Zones.getMinMax(points)
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
}