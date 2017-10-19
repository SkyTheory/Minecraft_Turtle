version = 1.00

requireAPI("Map")

function reloadCoord(w, d, h, f)
  return function(info)
    info.coord:reload(w, d, h, f)
  end
end

function setState(s, ...)
  local args = {...}
  return function(info)
    local nc = info.coord:getNextCoord(unpack(args))
    return (info.map:setState(nc.x, nc.y, nc.z, s))
  end
end

function traceRoute(info)
  -- Resume
  if (not info.route) then return end
  local next = info.route[1]
  if (next == nil or next == "EXIT") then
    info.route = nil
    return
  end
  local flag
  local dir = TurtleEx.rotate(next)
  if (next == "RIGHT" or next == "LEFT") then
    flag = true
  else
    flag = TurtleEx.move(dir)
  end
  if (flag) then
    table.remove(info.route, 1)
  else
    info.route = "CLOSED"
  end
end
