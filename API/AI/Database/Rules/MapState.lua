version = 1.00

requireAPI()

function coord(x, y, z, f)
  return function(info)
    if (x == info.coord.x and y == info.coord.y and z == info.coord.z) then
      if (not f) then return true end
      if (f == info.coord.facing) then
        return true
      end
    end
    return false
  end
end

function compare(key, op, var)
  local operation = op or "=="
  if (operation == "==") then
    return function(info)
      return (info.coord[key] == var)
    end
  end
  if (operation == "~=") then
    return function(info)
      return (info.coord[key] ~= var)
    end
  end
  if (operation == "<") then
    return function(info)
      return (info.coord[key] < var)
    end
  end
  if (operation == "<=") then
    return function(info)
      return (info.coord[key] <= var)
    end
  end
  if (operation == ">") then
    return function(info)
      return (info.coord[key] > var)
    end
  end
  if (operation == ">=") then
    return function(info)
      return (info.coord[key] >= var)
    end
  end
end

function getState(s, ...)
  local args = {...}
  return function(info)
    local nc = info.coord:getNextCoord(unpack(args))
    return (info.map:getState(nc.x, nc.y, nc.z) == s)
  end
end
