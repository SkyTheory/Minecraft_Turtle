version = 1.00

requireAPI("Map")

function setRoute(obj)
  local condition = function(info, node)
    return (info.map:getState(node.x, node.y, node.z) == obj)
  end
  return function(info)
    local route = getRoute(info, condition)
    info.route = route
  end
end

--------

function getRoute(info, condition)
  local route = {}
  local rc = GIWUtil.copy(info.coord.fields)
  local width = info.range.width
  local depth = info.range.depth
  repeat
    local next
    if (rc.x % 2 == 0) then
      if (rc.z > depth) then
        rc.z = rc.z - 1
        if (not condition(info, rc)) then break end
        next = "NORTH"
      else
        if (rc.x < width) then
          rc.x = rc.x + 1
          if (not condition(info, rc)) then break end
          next = "EAST"
        end
      end
    else
      if (rc.z < 0) then
        rc.z = rc.z + 1
        if (not condition(info, rc)) then break end
        next = "SOUTH"
      else
        if (rc.x < width) then
          rc.x = rc.x + 1
          if (not condition(info, rc)) then break end
          next = "EAST"
        end
      end
    end
    if (next ~= nil) then
      table.insert(route, next)
    end
  until(next == nil)
  if (next(route)) then
    table.insert(route, "EXIT")
    return route
  end
  return nil
end
