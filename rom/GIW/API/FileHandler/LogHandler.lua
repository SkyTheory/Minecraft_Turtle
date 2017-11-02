version = "2.50"

dependency.require("GIWUtil", "FileHandler")
dependency.after("GIWUtil", "FileHandler")
dependency.before()

local limitbackup = 0
local debugmode = false
local simplificationTime = 180

function constructor(self, tbl, name)
  self.loglist = {}
  self.logtable = tbl
  self.indexk = {}
  self.indexk["nil"] = -1
  self.indexk["newTable"] = -2
  self.indexn = {}
  self.indexn[-1] = "nil"
  self.indexn[-2] = "{}"
  self.tempkeys = {}
  self.logday = 0
  self.logtime = 0
  self.slogpos = os.day() * 24 + os.time()
  self.path = fs.combine("/GIW/log", name)
  self.data = FileHandler:instance(fs.combine(self.path, "data"))
  self.index = FileHandler:instance(fs.combine(self.path, "index"))
  self.temp = FileHandler:instance(fs.combine(self.path, "temp"))
  self:loadIndex()
end

function saveLog(self)
  if (not self.index:exists()) then
    self:saveIndex()
  end
  local lines = {}
  if (self.data:exists()) then
    self.data:open("r")
    for line in self.data.handler.readLine do
      table.insert(lines, line)
    end
    self.data:close()
  end
  local log = table.concat(lines)
  local change = self:getChange()
  if next(change) then
    local timeStamp = self:timeStamp()
    if (timeStamp) then
      log = string.format("%s%s", log, timeStamp)
    end
    for k, v in ipairs(change) do
      local data = self:writeLog(v)
      log = string.format("%s%s", log, data)
    end
  end
  if (self.slogpos < os.day() * 24 + os.time() - simplificationTime * 0.02) then
    log = self:simplification(log)
    self.slogtime = os.day() * 24 + os.time()
  end
  self.data:open("w")
  self.data:saveString(log)
  self.data:close()
  self:saveIndex()
  self.logday = os.day()
  self.logtime = os.time()
end

--[[
function saveLog(self)
  if (not self.index:exists()) then
    self:saveIndex()
  end
  local log = {}
  self.data:open("a")
  local change = self:getChange()
  if next(change) then
    self:timeStamp()
    for k, v in ipairs(change) do
      self:writeLog(v)
    end
  end
  self.data:save()
  self.data:close()
  self:saveIndex()
  self:simplification()
  self.logday = os.day()
  self.logtime = os.time()
end
--]]

function loadLog(self)
  if (not self.data:exists()) then return end
  self:loadIndex()
  self.data:open("r")
  GIWUtil.deplenish(self.logtable)
  local lines = {}
  for line in self.data.handler.readLine do
    table.insert(lines, line)
  end
  local log = table.concat(lines)
  for i, data in ipairs(GIWUtil.split(log, "$")) do
    if (string.match(data, "^@")) then
      if (not checkTimeStamp(data)) then break end
    else
      self:decode(self.logtable, data)
    end
  end
  GIWUtil.restoreMetaTable(self.logtable)
  self.data:close()
  self:backupLog()
  self:saveLog()
end

function setTemporaryData(self, key)
  self.tempkeys[GIWUtil.serialize(key)] = true
end

function delete(self)
  self.data:delete()
  self.index:delete()
  self.temp:delete()
end

------------------------

function saveIndex(self)
  self.index:open("w")
  for i, v in ipairs(self.indexn) do
    self.index:writeString(v)
  end
  self.index:close()
  self.temp:open("w")
  for key, v in next, self.tempkeys do
    self.temp:writeString(key)
  end
  self.temp:close()
end

function loadIndex(self)
  if (not self.index:exists()) then return end
  self.index:open("r")
  for line in self.index.handler.readLine do
    self:registerIndex(line)
  end
  self.index:close()
  if (not self.temp:exists()) then return end
  self.temp:open("r")
  for line in self.temp.handler.readLine do
    self:setTemporaryData(GIWUtil.unserialize(line))
  end
  self.temp:close()
end

function registerIndex(self, key)
  if (self.indexk[key] == nil) then
    table.insert(self.indexn, key)
    self.indexk[key] = #self.indexn
  end
end

function getChange(self)
  local old = GIWUtil.copy(self.loglist)
  local new = GIWUtil.copy(self.logtable)
  for i, v in next, self.tempkeys do
    local key = GIWUtil.unserialize(i)
    new[key] = nil
  end
  local log = {}
  local index = {}
  getUpdate(old, new, log)
  getRemove(old, new, log)
  self.loglist = new
  return log
end

function getUpdate(var1, var2, log, it)
  local old = var1
  local new = var2
  local index = it or {}
  for k, v in next, new do
    local kindex = GIWUtil.copy(index)
    table.insert(kindex, k)
    if (type(v) == "table") then
      local kold = old[k]
      if (type(kold) ~= "table") then
        kold = {}
        table.insert(log, {index = kindex, value = "newTable"})
      end
      getUpdate(kold, v, log, kindex)
    else
      if (old[k] ~= v) then
        table.insert(log, {index = kindex, value = v})
      end
      old[k] = nil
    end
  end
end

function getRemove(var1, var2, log, it)
  local old = var1
  local new = var2
  local index = it or {}
  for k, v in next, old do
    local kindex = GIWUtil.copy(index)
    table.insert(kindex, k)
    if (type(v) == "table" and new[k] ~= nil) then
      getRemove(old[k], new[k], log, kindex)
    else
      table.insert(log, {index = kindex, value = nil})
    end
  end
end

function writeLog(self, v)
  local index = self:keyProcessing(v.index)
  local value = self:keyProcessing(v.value)
  if (debugmode) then
    index = self:keyDecryption(index)
    value = self:keyDecryption(value)
  end
  local data = string.format("$%s:%s", index, value)
  return data
end

function decode(self, tbl, data)
  local list = GIWUtil.split(data, ":")
  local index
  local value
  if (debugmode) then
    index = list[1]
    value = list[2]
    value = GIWUtil.unserialize(value)
  else
    index = self:keyDecryption(list[1])
    value = self:keyDecryption(list[2])
    value = GIWUtil.unserialize(value)
  end
  GIWUtil.setByIndex(tbl, index, value, true)
end

function keyProcessing(self, obj)
  local objtype = type(obj)
  if (objtype == "number") then
    return string.format("#%s", tostring(obj))
  elseif (objtype ~= "table") then
    local key
    if (obj == "newTable") then
      key = "{}"
    else
      key = GIWUtil.serialize(obj)
    end
    self:registerIndex(key)
    return self.indexk[key]
  else
    local t = {}
    for i, key in ipairs(obj) do
      table.insert(t, self:keyProcessing(key))
    end
    return table.concat(t, ".")
  end
end

function keyDecryption(self, obj)
  local list = GIWUtil.split(obj, ".")
  local keys = {}
  for i, key in ipairs(list) do
    if (string.match(key, "^#")) then
      keys[i] = string.sub(key, 2)
    else
      keys[i] = self.indexn[tonumber(key)]
    end
  end
  return table.concat(keys, ".")
end

function simplification(self, log)
  local simpleLog = {}
  local backtime = os.day() * 24 + os.time() - simplificationTime * 0.02
  if (not self.data:exists()) then return log end
  local logDatas = GIWUtil.split(log, "$")
  local oldDatas = {}
  local pindex = 0
  for i, data in ipairs(logDatas) do
    if (string.match(data, "^@")) then
      if (not checkTimeStamp(data, backtime)) then
        pindex = i - 1
        break
      end
    else
      table.insert(oldDatas, data)
    end
  end
  for i, v in ipairs(oldDatas) do
    self:decode(simpleLog, v)
  end
  local sclog = {}
  getUpdate({}, simpleLog, sclog)
  local result = self:timeStamp(backtime) -- or ""
  if (#sclog == 0) then result = "" end
  for k, v in ipairs(sclog) do
    result = string.format("%s%s", result, self:writeLog(v))
    if (debugmode) then
      result = string.format("%s\n", result)
    end
  end
  for i, v in ipairs(logDatas) do
    result = string.format("%s$%s", result, v)
    if (debugmode) then
      result = string.format("%s\n", result)
    end
  end
  return result
end

function backupLog(self)
  if (not self.data:exists()) then return end
  if (not self.index:exists()) then return end
  backup(self.path, "data", limitbackup)
  backup(self.path, "index", limitbackup)
  backup(self.path, "temp", limitbackup)
end

function backup(dir, name, limit)
  for i = limit, 1, -1 do
    local frompath
    local bdir = string.gsub(dir, "/log/", "/log_backup/")
    if (i == 1) then
      frompath = string.format("%s.txt", fs.combine(dir, name))
    else
      frompath = string.format("%s_%s.txt", fs.combine(bdir, name), i - 1)
    end
    if (fs.exists(frompath)) then
      local topath = string.format("%s_%s.txt", fs.combine(bdir, name), i)
      if (fs.exists(topath)) then
        fs.delete(topath)
      end
      fs.move(frompath, topath)
    end
  end
end

function timeStamp(self, pos)
  local ts = pos or (os.day() * 24 + os.time())
  if (ts == self.logday * 24 + self.logtime) then return nil end
  local data = string.format("$@%f", ts)
  if (debugmode) then
    data = string.format("%s\n", data)
  end
  return data
end

function checkTimeStamp(line, pos)
  local tsstr = string.sub(line, 2)
  local tspos = tonumber(tsstr)
  local cpos = pos or (os.day() * 24 + os.time())
  if (tspos > cpos) then return false end
  return true
end

function enabledebug()
  debugmode = true
end
