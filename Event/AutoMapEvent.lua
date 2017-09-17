version = "2.10"

dependency.require("EventHandler", "Coordinate", "AutoMap", "MoveEvent")
dependency.after("EventHandler", "DigExtension", "Coordinate", "AutoMap", "MoveEvent")
dependency.before("TurtleEx")

local autoMap

local obstruction = "+"

function init()
  autoMap = AutoMap.getMap()
  registerEvent()
end

function registerEvent()
  --** Registered by MoveEvent API **--
  --turtle.forward = EventHandler.register(turtle.forward)
  --turtle.back = EventHandler.register(turtle.back)
  --turtle.up = EventHandler.register(turtle.up)
  --turtle.down = EventHandler.register(turtle.down)
  EventHandler.addEvent(turtle.forward, extendEvent)
  EventHandler.addEvent(turtle.back, extendEvent)
  EventHandler.addEvent(turtle.up, extendEvent)
  EventHandler.addEvent(turtle.down, extendEvent)
  if (DigExtension) then
    DigExtension.dig = EventHandler.register(DigExtension.dig)
    DigExtension.digUp = EventHandler.register(DigExtension.digUp)
    DigExtension.digDown = EventHandler.register(DigExtension.digDown)
    EventHandler.addEvent(DigExtension.dig, digEvent)
    EventHandler.addEvent(DigExtension.digUp, digUpEvent)
    EventHandler.addEvent(DigExtension.digDown, digDownEvent)
  else
    turtle.dig = EventHandler.register(turtle.dig)
    turtle.digUp = EventHandler.register(turtle.digUp)
    turtle.digDown = EventHandler.register(turtle.digDown)
    EventHandler.addEvent(turtle.dig, ndigEvent)
    EventHandler.addEvent(turtle.digUp, ndigUpEvent)
    EventHandler.addEvent(turtle.digDown, ndigDownEvent)

  end
end

function extendEvent(flag)
  if (flag) then
    local c = Coordinate.getCoord()
    autoMap:extend(c.width, c.depth, c.height)
  end
end

function obstructed(dir)
  local nc = Coordinate.getNextCoord(dir)
  autoMap:setValue(nc.width, nc.depth, nc.height, "display", obstruction)
end

function digEvent(flag)
  if (not flag) then
    obstructed("FORWARD")
  end
end

function digUpEvent(flag)
  if (not flag) then
    obstructed("UP")
  end
end

function digDownEvent(flag)
  if (not flag) then
    obstructed("DOWN")
  end
end

function ndigEvent(flag, err)
  if (not flag and err == "Unbreakable block detected") then
    obstructed("FORWARD")
  end
end

function ndigUpEvent(flag, err)
  if (not flag and err == "Unbreakable block detected") then
    obstructed("UP")
  end
end

function ndigDownEvent(flag, err)
  if (not flag and err == "Unbreakable block detected") then
    obstructed("DOWN")
  end
end

init()
