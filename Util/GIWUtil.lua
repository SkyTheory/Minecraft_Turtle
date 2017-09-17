version = "2.00"

dependency.require()
dependency.after()
dependency.before("MapManager", "TurtleEx")

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

function cast(data, dtype)
  if (dtype == "nil") then
    return nil
  end
  if (dtype == "string") then
    return tostring(data)
  end
  if (dtype == "number") then
    return tonumber(data)
  end
  if (dtype == "boolean") then
    if (data == "true") then
      return true
    end
    if (data == "false") then
      return false
    end
  end
  if (dtype == "table") then
    local dt = split(data, ",%s")
    return cast(dt[1], dt[2]), cast(dt[3], dt[4])
  end
  if (dtype == "function") then
    return getByIndex(_ENV, data)
  end
  return data
end

function getByIndex(base, path)
  local index = base
  local dt = {}
  for d in string.gmatch(path, "[^%.]+") do
    table.insert(dt, d)
  end
  for i, var in next, dt do
    if (index[var] == nil) then
      print("Tracing failed")
      return nil
    end
    index = index[var]
  end
  return index
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
      table.insert(list, obj)
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
