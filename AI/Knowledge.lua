local version = "1.00"

dependency.require("TurtleEx", "Inventory", "Map", "KnowledgeBase")
dependency.after("TurtleEx", "Inventory", "Map", "KnowledgeBase")
dependency.before()

local actlist = {}
local triggerlist = {}

local actpath = "/API/AI/Act"
local triggerpath = "/API/AI/Trigger"

function init()
  readRules(actpath, actlist)
  readRules(triggerpath, triggerlist)
end

function constructor(self, trigger, act, priority)
  self.trigger = trigger
  self.act = act
  self.priority = priority or 0
end

function addTrigger(self, func)
  local org = self.trigger
  self.trigger = function(info)
    return (org(info) and func(info))
  end
end

function addAct(self, func)
  local org = self.act
  self.act = function(info)
    org(info)
    func(info)
  end
end

function register(self, state)
  KnowledgeBase.addKnowledge(self, state)
end

function getActList()
  return actlist
end

function getTriggerList()
  return triggerlist
end

function readRules(path, tbl)
  local list = fs.list(path)
  for i, v in ipairs(list) do
    local env = {}
    setmetatable(env, {__index = _ENV})
    local filepath = fs.combine(path, v)
    if (not fs.isDir(filepath)) then
      local name = string.gsub(fs.getName(filepath), ".lua", "")
      local func = loadfile(filepath, env)
      local ok, err = pcall(func)
      if (ok) then
        tbl[name] = {}
        for k, v in next, env do
          if (k ~= "_ENV") then
            tbl[name][k] = v
          end
        end
      else
        GIWUtil.colorText("Knowledge: Error rule reading", colors.red)
        GIWUtil.colorText(err, colors.red)
      end
    end
  end
end

init()
