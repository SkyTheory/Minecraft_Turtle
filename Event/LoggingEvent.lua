version = "1.00"

dependency.require("LogHandler")
dependency.after("LogHandler", "MoveExtension")
dependency.before()

local linkedLogger = {}

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
  EventHandler.addEvent(turtle.forward, logEvent)
  EventHandler.addEvent(turtle.back, logEvent)
  EventHandler.addEvent(turtle.turnRight, logEvent)
  EventHandler.addEvent(turtle.turnLeft, logEvent)
  EventHandler.addEvent(turtle.up, logEvent)
  EventHandler.addEvent(turtle.down, logEvent)
end

function linkLog(log)
  linkedLog[log] = true
end

function logEvent(flag)
  if (flag) then
    for log, v in next, linkedLog do
      log.open(log, "a")
      log.saveLog(log)
      log.close(log)
    end
  end
end
