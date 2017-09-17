version = "1.00"

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

function writeData(self, key, var)
  self.handler.writeLine(string.format("%s : %s", key, GIWUtil.serialize(var)))
end

function save(self)
  self.handler.flush()
end

function saveString(self, str)
  self:writeString(str)
  self:save()
end

function saveData(self, key, var)
  self:writeData(key, var)
  self:save()
end

function timeStamp(self)
  self:saveString(string.format("@TimeStamp/%i/%f", os.day(), os.time()))
end

function loadData(self)
  local result = {}
  for line in self.handler.readLine do
    if (string.sub(line, 1, 1) == "@") then
      if (not checkTimeStamp(line)) then return result end
    else
      local key, var = unserialize(line)
      if (key) then
        result[key] = var
      end
    end
  end
  return result
end

function loadDataList(self)
  local result = {}
  for line in self.handler.readLine do
    if (string.sub(line, 1, 1) == "@") then
      if (not checkTimeStamp(line)) then return result end
    else
      local key, var = unserialize(line)
      if (key) then
        result[key] = result[key] or {}
        table.insert(result[key], var)
      end
    end
  end
  return result
end

function checkTimeStamp(line)
  if (string.match(line, "^@TimeStamp")) then
    local ts = GIWUtil.split(line, "/")
    local tsday = tonumber(ts[2])
    local tstime = tonumber(ts[3])
    if (tsday > os.day()) then return result end
    if (tsday == os.day() and tstime > os.time()) then return false end
  end
  return true
end

function unserialize(line)
  local list = GIWUtil.split(line, ":")
  if (next(list)) then
    local key = list[1]
    table.remove(list, 1)
    local data = table.concat(list, ":")
    var = GIWUtil.unserialize(data)
    return key, var
  end
  return nil
end
