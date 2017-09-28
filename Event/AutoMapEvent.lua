version = "2.30"

dependency.require("EventHandler", "Coordinate", "AutoMap", "MoveEvent")
dependency.after("EventHandler", "DigExtension", "Coordinate", "AutoMap", "MoveEvent")
dependency.before("MoveExtension", "TurtleEx")

local autoMap

local coord
local obstruction = "+"
local blank = "."

function init()
  registerEvent()
end

function registerEvent()
  --** Registered by MoveEvent API **--
  --turtle.forward = EventHandler.register(turtle.forward)
  --turtle.back = EventHandler.register(turtle.back)
  --turtle.up = EventHandler.register(turtle.up)
  --turtle.down = EventHandler.register(turtle.down)
  if (DigExtension) then
    DigExtension.dig = EventHandler.register(DigExtension.dig)
    DigExtension.digUp = EventHandler.register(DigExtension.digUp)
    DigExtension.digDown = EventHandler.register(DigExtension.digDown)
  else
    turtle.dig = EventHandler.register(turtle.dig)
    turtle.digUp = EventHandler.register(turtle.digUp)
    turtle.digDown = EventHandler.register(turtle.digDown)
  end
end

function registerMap(map, coord)
  EventHandler.addEvent(turtle.forward, blankEvent(map, coord))
  EventHandler.addEvent(turtle.back, blankEvent(map, coord))
  EventHandler.addEvent(turtle.up, blankEvent(map, coord))
  EventHandler.addEvent(turtle.down, blankEvent(map, coord))
  if (DigExtension) then
    EventHandler.addEvent(DigExtension.dig, digEvent(map, coord))
    EventHandler.addEvent(DigExtension.digUp, digUpEvent(map, coord))
    EventHandler.addEvent(DigExtension.digDown, digDownEvent(map, coord))
  else
    EventHandler.addEvent(turtle.dig, digEvent(map, coord))
    EventHandler.addEvent(turtle.digUp, digUpEvent(map, coord))
    EventHandler.addEvent(turtle.digDown, digDownEvent(map, coord))
  end
end

function blankEvent(map, coord)
  return function(flag)
    if (flag) then
      map:setValue(coord.x, coord.y, coord.z, "state", "blank")
      map:setValue(coord.x, coord.y, coord.z, "display", blank)
    end
  end
end

function obstructed(map, coord, dir)
  local nc = coord:getNextCoord(dir)
  map:setValue(nc.x, nc.y, nc.z, "state", "obstruction")
  map:setValue(nc.x, nc.y, nc.z, "display", obstruction)
end

function digEvent(map, coord)
  return function(flag, err)
    if (not flag and (err == "Unbreakable block detected" or err == "Protected block detected")) then
      obstructed(map, coord, "FORWARD")
    end
  end
end

function digUpEvent(map, coord)
  return function(flag, err)
    if (not flag and (err == "Unbreakable block detected" or err == "Protected block detected")) then
      obstructed(map, coord, "UP")
    end
  end
end

function digDownEvent(map, coord)
  return function(flag, err)
    if (not flag and (err == "Unbreakable block detected" or err == "Protected block detected")) then
      obstructed(map, coord, "DOWN")
    end
  end
end

init()
