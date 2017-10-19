version = "1.00"

dependency.require("GIWUtil", "FileHandler")
dependency.after("GIWUtil", "FileHandler")
dependency.before()

extends("FileHandler")

function constructor(self, name)
  super.constructor(self, fs.combine("/config", name))
end

function writeData(self, key, var)
  self:writeString(string.format("%s : %s", key, GIWUtil.serialize(var)))
end

function saveData(self, key, var)
  self:writeData(key, var)
  self:save()
end

function loadData(self)
  local result = {}
  for line in self.handler.readLine do
    if (string.sub(line, 1, 1) ~= "@") then
      local key, var, change = unserialize(line)
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
    if (string.sub(line, 1, 1) ~= "@") then
      local key, var = unserialize(line)
      if (key) then
        result[key] = result[key] or {}
        table.insert(result[key], var)
      end
    end
  end
  return result
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
