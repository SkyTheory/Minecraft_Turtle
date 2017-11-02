version = "1.00"

dependency.require()
dependency.after()
dependency.before()

function condition(obj)
  local var
  local cflag
  local ccoord
  if (type(obj) == "string") then
    var = {obj}
  elseif(type(obj) == "table") then
    var = GIWUtil.copy(obj)
    if (var.x or var.y or var.z) then
      cflag = true
      ccoord = {x = var.x, y = var.y, z = var.z}
      var.x = nil
      var.y = nil
      var.z = nil
    end
    if (var.coord) then
      cflag = true
      ccoord = {x = var.coord.x, y = var.coord.y, z = var.coord.z}
      var.coord = nil
    end
  else
    error("condition: Invalid value")
  end
  return function(info, node)
    for i, state in ipairs(var) do
      if (info.map:getState(node.x, node.y, node.z) == state) then return true end
    end
    if (cflag) then
      cx = ccoord.x or info.coord.x
      cy = ccoord.y or info.coord.y
      cz = ccoord.z or info.coord.z
      if (node.x == cx and node.y == cy and node.z == cz) then
        return true
      end
    end
  end
end

function isRange(info, node)
  if (node.x < info.range.minWidth) then return false end
  if (node.x > info.range.maxWidth) then return false end
  if (node.z < info.range.minDepth) then return false end
  if (node.z > info.range.maxDepth) then return false end
  return true
end
