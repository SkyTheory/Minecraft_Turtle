version = 1.00

requireAPI("Map")

function setRoute(obj, index)
  local condition
  if (type(obj) == "table") then
    local cx = obj.x or info.coord.x
    local cz = obj.z or info.coord.z
    condition = function(info, node)
      return (node.x == cx and node.z == cz)
    end
  end
  if (type(obj) == "string") then
    if (obj == "index") then
      condition = function(info, node)
        return (node.x == info[index].x and node.z == info[index].z)
      end
    else
      condition = function(info, node)
        return (info.map:getState(node.x, node.y, node.z) == obj)
      end
    end
  end
  return function(info)
    local route = getRoute(info, condition)
    info.route = route
  end
end

--------

function getRoute(info, condition)
  local bfMap = {}
  local open = {}
  for i = math.min(info.range.width, 0), math.max(info.range.width, 0) do
    bfMap[i] = {}
  end
  local snode = GIWUtil.copy(info.coord.fields)
  snode.route = {}
  open[1] = {}
  open[1][1] = snode
  bfMap[snode.x][snode.z] = true
  for i, rate in ipairs(open) do
    for j, node in ipairs(rate) do
      local forward = getNext(info, bfMap, open, node, "FORWARD")
      if (forward and condition(info, forward)) then
        return forward.route
      end
      local right = getNext(info, bfMap, open, node, "RIGHT", "FORWARD")
      if (right and condition(info, right)) then
        return right.route
      end
      local left = getNext(info, bfMap, open, node, "LEFT", "FORWARD")
      if (left and condition(info, left)) then
        return left.route
      end
      local back = getNext(info, bfMap, open, node, "RIGHT", "RIGHT", "FORWARD")
      if (back and condition(info, back)) then
        return back.route
      end
    end
  end
end

function getNext(info, bfMap, open, node, ...)
  local args = {...}
  local nextnode = Coordinate.getNextCoord(node, ...)
  if (info.map:getState(nextnode.x, nextnode.y, nextnode.z) ~= "obstruction") then
    if (inRange(info, nextnode) and not bfMap[nextnode.x][nextnode.z]) then
      nextnode.route = GIWUtil.copy(node.route)
      for i, v in ipairs(args) do
        table.insert(nextnode.route, v)
      end
      for i = #open + 1, #nextnode.route do
        open[i] = open[i] or {}
      end
      table.insert(open[#nextnode.route], nextnode)
      bfMap[nextnode.x][nextnode.z] = true
      return nextnode
    end
  end
  return nil
end

function inRange(info, node)
  local minx = math.min(info.range.width, 0)
  local maxx = math.max(info.range.width, 0)
  local minz = math.min(info.range.depth, 0)
  local maxz = math.max(info.range.depth, 0)
  if (node.x < minx or node.x > maxx) then return false end
  if (node.z < minz or node.z > maxz) then return false end
  return true
end
