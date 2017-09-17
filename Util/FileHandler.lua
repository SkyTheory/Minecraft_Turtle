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
  local data
  if (type(var) ~= "table") then
    data = tostring(var)
  else
    local dtbl = {}
    for tkey, tvar in next, var do
      local str = string.format("%s, %s, %s, %s", tkey, type(tkey), tostring(tvar), type(tvar))
      table.insert(dtbl, str)
    end
    data = table.concat(dtbl, "/")
  end
  self.handler.writeLine(string.format("%s/%s/%s", key, type(var), data))
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
      local list = GIWUtil.split(line, "/")
      if (list[1] == "@TimeStamp") then
        local tsday = tonumber(list[2])
        local tstime = tonumber(list[3])
        if (tsday > os.day()) then return result end
        if (tsday == os.day() and tstime > os.time()) then return result end
      end
    else
      local list = GIWUtil.split(line, "/")
      if (next(list) ~= nil) then
        local dataindex = list[1]
        table.remove(list, 1)
        local datatype = list[1]
        table.remove(list, 1)
        for key, var in ipairs(list) do
          local r1, r2 = GIWUtil.cast(var, datatype)
          if (datatype ~= "table") then
            result[dataindex] = r1
          else
            result[dataindex] = result[dataindex] or {}
            --
            result[dataindex][r1] = r2
          end
        end
      end
    end
  end
  return result
end

function loadDataList(self)
  local result = {}
  for line in self.handler.readLine do
    if (string.sub(line, 1, 1) == "@") then
      local list = GIWUtil.split(line, "/")
      if (list[1] == "@TimeStamp") then
        local tsday = tonumber(list[2])
        local tstime = tonumber(list[3])
        if (tsday > os.day()) then return result end
        if (tsday == os.day() and tstime > os.time()) then return result end
      end
    else
      local list = GIWUtil.split(line, "/")
      if (next(list) ~= nil) then
        local dataindex = list[1]
        table.remove(list, 1)
        local datatype = list[1]
        table.remove(list, 1)
        result[dataindex] = result[dataindex] or {}
        local nextindex = #result[dataindex] + 1
        for key, var in ipairs(list) do
          local r1, r2 = GIWUtil.cast(var, datatype)
          if (datatype ~= "table") then
            result[dataindex][nextindex] = r1
          else
            result[dataindex][nextindex] = result[dataindex][nextindex] or {}
            result[dataindex][nextindex][r1] = r2
          end
        end
      end
    end
  end
  return result
end
