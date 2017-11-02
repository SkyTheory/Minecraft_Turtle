version = 1.01

function coord(x, y, z, f)
  return function(info)
    if (x ~= nil and x ~= info.coord.x) then return false end
    if (y ~= nil and y ~= info.coord.y) then return false end
    if (z ~= nil and z ~= info.coord.z) then return false end
    if (f ~= nil and f ~= info.coord.facing) then return false end
    return true
  end
end

function xCoord(x)
  return function(info)
    return (info.coord.x == x)
  end
end

function yCoord(y)
  return function(info)
    return (info.coord.y == y)
  end
end

function zCoord(z)
  return function(info)
    return (info.coord.z == z)
  end
end

function facing(f)
  return function(info)
    return (info.coord.facing == f)
  end
end

function getState(s, ...)
  local args = {...}
  return function(info)
    local nc = info.coord:getNextCoord(unpack(args))
    return (info.map:getState(nc.x, nc.y, nc.z) == s)
  end
end
