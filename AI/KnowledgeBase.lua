local version = "1.00"

dependency.require("Inventory", "Map", "TurtleEx", "LogHandler")
dependency.after("Inventory", "Map", "TurtleEx", "LogHandler")
dependency.before()

local status = {}
local stateIndex = {}
local knowledgeBase = {}

function init()
  status[0] = "init"
  stateIndex["init"] = 0
  knowledgeBase["init"] = {}
end

function addStatus(name)
  table.insert(status, name)
  stateIndex[name] = #status
  knowledgeBase[name] = {}
end

function addKnowledge(obj, state)
  obj.state = state
  obj.index = #knowledgeBase[state] + 1
  knowledgeBase[state][obj.index] = obj
end

function getNextEvent(info)
  local nextEvent
  for i, v in ipairs(knowledgeBase[info.state]) do
    if (v.trigger(info)) then
      if (not nextEvent) then
        nextEvent = v
      elseif (nextEvent.priority <= v.priority) then
        nextEvent = v
      end
    end
  end
  return nextEvent
end

function getNextState(state)
  local index = stateIndex[state] + 1
  return status[index] or status[1]
end

function getList()
  return knowledgeBase
end

init()
