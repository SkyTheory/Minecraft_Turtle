version = "1.01"

dependency.require("GIWUtil")
dependency.after("GIWUtil")
dependency.before()

function constructor(self, name)
  self.path = string.format("%s.txt", name)
end

function exists(self)
  return fs.exists(self.path)
end

function open(self, mode)
  if (self.handler ~= nil) then self:close() end
  self.handler = fs.open(self.path, mode)
end

function close(self)
  self.handler.close()
  self.handler = nil
end

function writeString(self, str)
  self.handler.writeLine(str)
end

function save(self)
  self.handler.flush()
end

function saveString(self, str)
  self:writeString(str)
  self:save()
end
