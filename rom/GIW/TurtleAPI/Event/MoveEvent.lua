version = "1.52"

dependency.require("EventHandler", "Coordinate")
dependency.after("EventHandler")
dependency.before("MoveExtension", "TurnExtension", "TurtleEx", "LoggingEvent")

local linkedCoord = {}

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
  EventHandler.addPostEvent(turtle.forward, moveEvent("FORWARD"))
  EventHandler.addPostEvent(turtle.back, moveEvent("BACK"))
  EventHandler.addPostEvent(turtle.turnRight, moveEvent("RIGHT"))
  EventHandler.addPostEvent(turtle.turnLeft, moveEvent("LEFT"))
  EventHandler.addPostEvent(turtle.up, moveEvent("UP"))
  EventHandler.addPostEvent(turtle.down, moveEvent("DOWN"))
end

function linkCoord(coord)
  linkedCoord[coord] = true
end

function moveEvent(key)
  return function(flag)
    if (flag) then
      for coord, v in next, linkedCoord do
        coord:update(key)
      end
    end
  end
end

init()
