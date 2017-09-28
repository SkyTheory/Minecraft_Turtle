version = "1.00"

dependency.require("GIWUtil", "FileHandler")
dependency.after("GIWUtil", "FileHandler")
dependency.before()

extends("FileHandler")

local debugmessage = false

function constructor(self, tbl, name)
  self.logList = {}
  self.logTable = tbl
  super.constructor(self, fs.combine("/log", name))
end

function saveLog(self)
  self:timeStamp()
  if (debugmessage) then
    print("--------")
  end
  local old = loglist[tbl] or {}
  local new = GIWUtil.copy(self.logTable)
  local update = {}
  local remove = {}
  getUpdate(old, new, update)
  for i, v in ipairs(update) do
    self:writeString(v)
    if (debugmessage) then
      print(v)
    end
  end
  getRemove(old, new, remove)
  for i, v in ipairs(remove) do
    self:writeString(v)
    if (debugmessage) then
      print(v)
    end
  end
  loglist[tbl] = new
  self:save()
end

function loadLog(self)
  local result = {}
  for line in self.handler.readLine do
    if (not checkTimeStamp(line)) then break end
    if (string.sub(line, 1, 1) ~= "@") then
      local list = GIWUtil.split(line, "=")
      local key = list[1]
      local var = GIWUtil.unserialize(list[2])
      GIWUtil.setByIndex(result, index, var, true)
    end
  end
  return result
end

function getUpdate(var1, var2, update, i)
  local t1 = var1
  local t2 = var2
  if (not t1) then
    t1 = {}
    table.insert(update, string.format("%s = %s", i, "{}"))
  end
  for k, v in next, t2 do
    local index
    if (i) then
      index = string.format("%s.%s", i, GIWUtil.serialize(k))
    else
      index = GIWUtil.serialize(k)
    end
    if (type(v) == "table") then
      getUpdate(t1[k], t2[k], update, index)
    else
      if (v ~= t1[k]) then
        table.insert(update, string.format("%s = %s", index, GIWUtil.serialize(v)))
      end
    end
  end
end

function getRemove(var1, var2, remove, i)
  local t1 = var1
  local t2 = var2
  for k, v in next, t1 do
    local index
    if (i) then
      index = string.format("%s.%s", i, GIWUtil.serialize(k))
    else
      index = GIWUtil.serialize(k)
    end
    if (type(v) == "table") then
      if (not t2[k]) then
        table.insert(remove, string.format("%s = nil", index))
      else
        getRemove(t1[k], t2[k], remove, index)
      end
    else
      if (not t2[k]) then
        table.insert(remove, string.format("%s = nil", index))
      end
    end
  end
end

function timeStamp(self)
  self:saveString(string.format("@TimeStamp/%i/%f", os.day(), os.time()))
end

function checkTimeStamp(line)
  if (string.match(line, "^@TimeStamp")) then
    local ts = GIWUtil.split(line, "/")
    local tsday = tonumber(ts[2])
    local tstime = tonumber(ts[3])
    if (tsday > os.day()) then return false end
    if (tsday == os.day() and tstime > os.time()) then return false end
  end
  return true
end
