version = 1.35

requireAPI("Map", "RouteUtil")

function setRoute(pass, goal)
  local passState = pass
  local goalState = goal or passState
  local passCondition = RouteUtil.condition(passState)
  local goalCondition = RouteUtil.condition(goalState)
  return function(info)
    local route = getRoute(info, passCondition, goalCondition)
    info.route = route
  end
end

--------

function getRoute(info, passCondition, goalCondition)
  local route = {}
  local vindex = 0
  local move
  local node = GIWUtil.copy(info.coord.fields)
  local direction
  local width = info.range.maxWidth
  local depth = info.range.minDepth
  repeat
    direction = nil
    move = false
    if (node.x % 2 == 0) then
      if (node.z > depth) then
        direction = "NORTH"
      elseif (node.x < width) then
        direction = "EAST"
      end
    else
      if (node.z < 0) then
        direction = "SOUTH"
      elseif (node.x < width) then
        direction = "EAST"
      end
    end
    if (direction == nil) then break end
    node = Coordinate.getNextCoord(node, direction)
    if (passCondition(info, node)) then
      table.insert(route, direction)
      move = true
      if (goalCondition(info, node)) then
        vindex = #route
      end
    elseif(goalCondition(info, node)) then
      table.insert(route, direction)
      vindex = #route
    end
  until(not move)
  if (vindex ~= 0) then
    local result = {}
    for i = 1, vindex do
      result[i] = route[i]
    end
    table.insert(result, "EXIT")
    return result
  end
  return nil
end
