version = 1.01

function obstruction()
  return function(info)
    local nc = info.coord:getNextCoord(info.mine)
    return (info.map:getState(nc.x, nc.y, nc.z) == "obstruction")
  end
end

function limitDepth()
  return function(info)
    if (info.mine == "UP") then
      return (info.coord.y + 1 >= info.range.maxHeight)
    end
    if (info.mine == "DOWN") then
      return (info.coord.y - 1 <= info.range.minHeight)
    end
  end
end
