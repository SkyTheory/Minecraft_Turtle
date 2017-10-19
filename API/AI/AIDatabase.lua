local version = "1.12"

dependency.require("Inventory", "Map", "TurtleEx", "LogHandler")
dependency.after("Inventory", "Map", "TurtleEx", "LogHandler")
dependency.before()

local status = {}
local stateIndex = {}
local database = {}
local conflict = {} -- key, lastfired
local resolve = "key"

function init()
  status[0] = "init"
  stateIndex["init"] = 0
  database["init"] = {}
  status[-1] = "undefined"
  stateIndex["undefined"] = -1
  database["undefined"] = {}
end

function addStatus(name)
  table.insert(status, name)
  stateIndex[name] = #status
  database[name] = database[name] or {}
end

function addData(obj)
  if (not database[obj.state]) then
    addStatus(obj.state)
  end
  database[obj.state][obj.key] = obj
end

function setResolveRule(name)
  resolve = name
end

function match(info)
  local matched = {}
  local maxPriority = -math.huge
  for name, data in next, database[info.state] do
    if (data:schedule(info)) then
      table.insert(matched, data)
      if (data.priority > maxPriority) then
        maxPriority = data.priority
      end
    end
  end
  local sifted = {}
  for i, data in ipairs(matched) do
    if (data.priority == maxPriority) then
      table.insert(sifted, data)
    end
  end
  local nextdata = conflict[resolve](sifted, info)
  if (nextdata) then
    return nextdata.key
  end
  return nil
end

function conflict.key(datas, info)
  table.sort(datas, function(data1, data2) return (data1.key < data2.key) end)
  return datas[1]
end

function conflict.lastfired(datas, info)
  local times = {}
  for i, v in ipairs(info.eventLog) do
    times[getKey(v)] = i
  end
  local first
  for i, v in ipairs(datas) do
    if (times[getKey(v)] == nil) then
      first = v
      break
    else
      if (first == nil) then
        first = v
      elseif(times[getKey(v)] < times[getKey(first)]) then
        first = v
      end
    end
  end
  return first
end

function makeKey(state, key)
  return string.format("%s:%s", state, key)
end

function getKey(data)
  return string.format("%s:%s", data.state, data.key)
end

function execute(info, key)
  database[info.state][key]:execute(info)
end

function getNextState(state)
  local index = stateIndex[state] + 1
  return status[index] or status[1]
end

function remove(obj)
  database[obj.state][obj.key] = nil
end

init()
