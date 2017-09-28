version = "1.50"

dependency.require("EventHandler", "Coordinate")
dependency.after("EventHandler")
dependency.before("MoveExtension", "TurtleEx")

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
  EventHandler.addEvent(turtle.forward, moveEvent("FORWARD"))
  EventHandler.addEvent(turtle.back, moveEvent("BACK"))
  EventHandler.addEvent(turtle.turnRight, moveEvent("RIGHT"))
  EventHandler.addEvent(turtle.turnLeft, moveEvent("LEFT"))
  EventHandler.addEvent(turtle.up, moveEvent("UP"))
  EventHandler.addEvent(turtle.down, moveEvent("DOWN"))
end

function linkCoord(coord)
  linkedCoord[coord] = true
end

function moveEvent(key)
  return function(flag)
    if (flag) then
      for coord, v in next, linkedCoord do
        coord.update[key](coord)
      end
    end
  end
end

init()
