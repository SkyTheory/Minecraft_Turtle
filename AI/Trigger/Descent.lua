-- version = 1.00

function descent(info)
  if (info.coord.y > info.nextY) then
    local nc = info.coord:getNextCoord("DOWN")
    if (info.map:getValue(nc.x, nc.y, nc.z, "state") ~= "obstruction") then
      return true
    end
  end
  return false
end

function updateNextY(info)
  if (info.coord.y == info.nextY) then
    return true
  end
  return false
end

function reachFloor(info)
  local nc = info.coord:getNextCoord("DOWN")
  if (info.map:getValue(nc.x, nc.y, nc.z, "state") == "obstruction") then
    return true
  end
  return false
end
