version = "1.02"

dependency.require("EventHandler", "LogHandler")
dependency.after("EventHandler", "LogHandler", "MoveExtension", "TurnExtension")
dependency.before("TurtleEx")

local linkedLog = {}

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
  EventHandler.addPostEvent(turtle.forward, logEvent)
  EventHandler.addPostEvent(turtle.back, logEvent)
  EventHandler.addPostEvent(turtle.turnRight, logEvent)
  EventHandler.addPostEvent(turtle.turnLeft, logEvent)
  EventHandler.addPostEvent(turtle.up, logEvent)
  EventHandler.addPostEvent(turtle.down, logEvent)
end

function linkLog(log)
  linkedLog[log] = true
end

function logEvent(flag)
  if (flag) then
    for log, v in next, linkedLog do
      log:saveLog()
    end
  end
end

init()
