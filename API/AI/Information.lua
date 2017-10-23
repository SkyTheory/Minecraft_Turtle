version = "1.21"

dependency.require("LogHandler", "Coordinate", "AutoMap")
dependency.after("LogHandler", "Coordinate", "AutoMap")
dependency.before()

local logs = {}

function constructor(self, logpath)
  if (logpath) then
    logs[self] = LogHandler:instance(self.fields, logpath)
    self:loadLog()
    LoggingEvent.linkLog(logs[self])
  end
  self.state = self.state or "init"
  self.eventLog = self.eventLog or {}
  if (self.fields.coord) then
    self.fields.coord:reload()
  else
    self.coord = Coordinate:instance(0, 0, 0, "NORTH", true)
  end
  if (self.fields.map) then
    self.fields.map:reload(self.fields.coord)
  else
    self.map = AutoMap:instance(self.coord)
  end
end

function setTemporaryData(self, key)
  if (logs[self]) then
    logs[self]:setTemporaryData(key)
  end
end

function saveLog(self)
  if (logs[self]) then
    logs[self]:saveLog()
  end
end

function loadLog(self)
  if (logs[self]) then
    logs[self]:loadLog()
  end
end

function deleteLog(self)
  if (logs[self]) then
    logs[self]:delete()
  end
end

function backupLog(self)
  if (logs[self]) then
    logs[self]:backupLog()
  end
end

function simplificationLog(self)
  if (logs[self]) then
    logs[self]:simplification()
  end
end
