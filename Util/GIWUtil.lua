version = "2.10"

dependency.require()
dependency.after()
dependency.before("MapManager", "TurtleEx")

-- set, getByIndex
local debugmessage = false

-- Argument

function fixRange(str)
  local num = tonumber(str)
  num = math.modf(num)
  if (not num) then return 0 end
  if (num > 0) then num = num - 1 end
  if (num < 0) then num = num + 1 end
  return num
end

-- Item / Block

function isIdentical(tbl1, tbl2, switch)
  if (tbl1 == nil) then return false end
  if (tbl2 == nil) then return false end
  local mode = {}
  mode["exact"] = {false, false}
  mode["auto"] = {false, true}
  mode["fuzzy"] = {true, true}
  local fList = mode[switch] or mode["auto"]
  local filter = fList[1]
  meta1 = tbl1.metadata or tbl1.damage
  meta2 = tbl2.metadata or tbl2.damage
  if (meta1 == nil) then filter = fList[2] end
  if (meta2 == nil) then filter = fList[2] end
  if (tbl1.name == tbl2.name) then
    if (filter or meta1 == meta2) then
      return true
    end
  end
  return false
end

-- Variable

function serialize(data, i, isTableKey)
  local indexes = i or {}
  local datatype = type(data)
  local datastr
  if (datatype == "nil") then
    return "nil"
  end
  if (datatype == "string") then
    return string.format("\"%s\"", data)
  end
  if (datatype == "number") then
    return tostring(data)
  end
  if (datatype == "boolean") then
    return tostring(data)
  end
  if (datatype == "table") then
    if (isTableKey) then
      error("Object has key which is table.")
    end
    if (indexes[data]) then
      error("Loop in index")
    end
    indexes[data] = true
    local tbl = {}
    for k, v in next, data do
      local kstr = string.format(serialize(k, indexes, true))
      local vstr = string.format(serialize(v, indexes, false))
      local tdata = string.format("%s = %s", kstr, vstr)
      table.insert(tbl, tdata)
    end
    return string.format("{%s}", table.concat(tbl, ", "))
  end
  error("Serialize failed")
  return nil
end

function unserialize(data)
  if (string.match(data, "^\".+\"$")) then
    -- "something"
    return string.sub(data, 2, -2)
  end
  if (string.match(data, "^{.+}$")) then
    -- {something}
    local obj = {}
    datastr = string.sub(data, 2, -2)
    datalist = split(datastr, ",")
    for i, v in ipairs(datalist) do
      local vlist = split(v, "=")
      local key = unserialize(vlist[1])
      local var = unserialize(vlist[2])
      obj[key] = var
    end
    if (obj.classname) then
      obj.super = {}
      setmetatable(obj, {__index = GIWCore.indexHandler(obj.fields, _ENV[obj.classname]), __newindex = obj.fields})
      setmetatable(obj.super, {__index = GIWCore.indexHandler(obj.fields, _ENV[obj.classname].super), __newindex = obj.fields})
    end
    return obj
  end
  if (data == "true") then return true end
  if (data == "false") then return false end
  if (data == "nil") then return nil end
  return tonumber(data) or data
end

function setByIndex(tbl, path, var, mkdir)
  local index = tbl
  local dt = {}
  for d in string.gmatch(path, "[^%.]+") do
    table.insert(dt, d)
  end
  for i, v in ipairs(dt) do
    local key = unserialize(v)
    if (i ~= #dt) then
      if (not index[key]) then
        if (mkdir) then
          index[key] = {}
        else
          if (debugmessage) then print("Tracing failed") end
          return
        end
      end
      index = index[key]
    else
      index[key] = var
    end
  end
end

function getByIndex(tbl, path, mkdir)
  local index = tbl
  local previndex
  local dt = {}
  for d in string.gmatch(path, "[^%.]+") do
    table.insert(dt, d)
  end
  for i, v in ipairs(dt) do
    local key = unserialize(v)
    previndex = index
    if (not previndex[key]) then
      if(i == #dt) then
        return nil
      elseif (mkdir) then
        previndex[key] = {}
      else
        if (debugmessage) then print("Tracing failed") end
        return nil
      end
    end
    index = previndex[key]
  end
  local lk = tonumber(dt[#dt]) or dt[#dt]
  return index
end

function formatIndex(...)
  local args = {...}
  local obj = {}
  for i, v in ipairs(args) do
    table.insert(obj, serialize(v))
  end
  return table.concat(obj, ".")
end

function copy(var, debug)
  if (debug) then
    print(type(var), var)
  end
  if (type(var) == "table") then
    local result = {}
    for k, v in next, var do
      if (type(v) ~= "table") then
        result[k] = v
      else
        result[k] = copy(v)
      end
    end
    return result
  else
    return var
  end
end

-- Util

function split(str, p)
  local list = {}
  if (type(p) == "string") then
    for obj in string.gmatch(str, string.format("[^%s]+", p)) do
      local objstr = string.gsub(obj, "^%s+", "")
      objstr = string.gsub(objstr, "%s+$", "")
      table.insert(list, objstr)
    end
  end
  if (type(p) == "number") then
    if (string.len(str) <= p) then
      table.insert(list, str)
    else
      local early = string.sub(str, 1, p)
      local late = string.sub(str, p + 1)
      table.insert(list, early)
      table.insert(list, late)
    end
  end
  return list
end

function setValue(key, var)
  GIWCore.setValue(key, var)
end

function colorText(str, c)
  GIWCore.colorText(str, c)
end
