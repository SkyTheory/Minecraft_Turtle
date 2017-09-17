version = "1.40"


dependency.require("EventHandler", "Coordinate")
dependency.after("EventHandler", "Coordinate")
dependency.before("TurtleEx")

local update = Coordinate.getUpdateFunctions()
local coord = Coordinate.getCoord()

function init()
  registerEvent()
end

function registerEvent()
  turtle.forward = EventHandler.register(turtle.forward)
  turtle.back = EventHandler.register(turtle.back)
  turtle.turnRight = EventHandler.register(turtle.turnRight)
  turtle.turnLeft = EventHandler.register(turtle.turnLeft)
  turtle.up = EventHandler.register(turtle.up)
  turtle.down = EventHandler.register(turtle.down)
  EventHandler.addEvent(turtle.forward, forwardEvent)
  EventHandler.addEvent(turtle.back, backEvent)
  EventHandler.addEvent(turtle.up, upEvent)
  EventHandler.addEvent(turtle.down, downEvent)
  EventHandler.addEvent(turtle.turnRight, turnRightEvent)
  EventHandler.addEvent(turtle.turnLeft, turnLeftEvent)
end

function forwardEvent(flag)
  if (flag) then
    update[coord.facing](coord)
  end
end

function backEvent(flag)
  if (flag) then
    update[Coordinate.synthesize(coord.facing, 2)](coord)
  end
end

function upEvent(flag)
  if (flag) then
    update.UP(coord)
  end
end

function downEvent(flag)
  if (flag) then
    update.DOWN(coord)
  end
end

function turnRightEvent(flag)
  if (flag) then
    update.RIGHT(coord)
  end
end

function turnLeftEvent(flag)
  if (flag) then
    update.LEFT(coord)
  end
end

init()
