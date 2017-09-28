local version = "1.00"

dependency.require("KnowledgeBase", "LogHandler", "LoggingEvent")
dependency.after("KnowledgeBase", "LogHandler", "LoggingEvent", "Coordinate")
dependency.before()

local info = {}
local log

function initInfo(logpath)
  if (logpath) then
    log = LogHandler:instance(logpath)
    if (log:exists()) then
      log:open("r")
      info = log:loadLog()
      if (info.coord) then
        local c = info.coord
        info.coord:reload()
      end
      log:close()
      log:open("a")
    else
      info.state = "init"
      log:open("w")
      log:saveLog()
    end
    LoggingEvent.linkLog(log)
  else
    info.state = "init"
  end
  turtle.select(1)
end

function engine(logpath)
  initInfo(logpath)
  while(info.state ~= "exit") do
    local nextEvent = KnowledgeBase.getNextEvent(info)
    if (nextEvent) then
      nextEvent.act(info)
      info.prevEvent = {state = nextEvent.state, index = nextEvent.index}
    else
      info.state = KnowledgeBase.getNextState(info.state)
    end
    if (log) then
      log:open("w")
      log:saveLog()
      log:close()
    end
  end
end
