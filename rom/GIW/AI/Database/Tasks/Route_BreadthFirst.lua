version = 1.20

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

function getRoute(info, pass, goal)
  local bfMap = {}
  local open = {}
  for i = info.range.minWidth, info.range.maxWidth do
    bfMap[i] = {}
  end
  local snode = GIWUtil.copy(info.coord.fields)
  snode.route = {}
  open[1] = {}
  open[1][1] = snode
  bfMap[snode.x][snode.z] = true
  for i, rate in ipairs(open) do
    for j, node in ipairs(rate) do
      local forward = getNext(info, bfMap, open, node, pass, goal, "FORWARD")
      if (forward and goal(info, forward)) then
        return forward.route
      end
      local right = getNext(info, bfMap, open, node, pass, goal,  "RIGHT", "FORWARD")
      if (right and goal(info, right)) then
        return right.route
      end
      local left = getNext(info, bfMap, open, node, pass, goal,  "LEFT", "FORWARD")
      if (left and goal(info, left)) then
        return left.route
      end
      local back = getNext(info, bfMap, open, node, pass, goal,  "RIGHT", "RIGHT", "FORWARD")
      if (back and goal(info, back)) then
        return back.route
      end
    end
  end
end

function getNext(info, bfMap, open, node, pass, goal, ...)
  local args = {...}
  local nextnode = Coordinate.getNextCoord(node, ...)
  if (info.map:getState(nextnode.x, nextnode.y, nextnode.z) ~= "obstruction") then
    if (RouteUtil.isRange(info, nextnode) and not bfMap[nextnode.x][nextnode.z]) then
      bfMap[nextnode.x][nextnode.z] = true
      if (pass(info, nextnode) or goal(info, nextnode)) then
        nextnode.route = GIWUtil.copy(node.route)
        for i, v in ipairs(args) do
          table.insert(nextnode.route, v)
        end
        for i = #open + 1, #nextnode.route do
          open[i] = open[i] or {}
        end
        table.insert(open[#nextnode.route], nextnode)
        return nextnode
      end
    end
  end
  return nil
end
