version = "1.10"

dependency.require("AIDatabase")
dependency.after("AIDatabase")
dependency.before()

local ruleType = {}
local rule = {}
local schedule = {}
local task = {}
local execute = {}

local kflag

function constructor(self, s, r, t, p)
  self.state = s or "undefined"
  self.index = "undefined"
  self.priority = p or 0
  self.setPriority = setPriority
  self.rtype = r or "SINGLE"
  self.ttype = t or "SINGLE"
  self.rules = {}
  self.tasks = {}
  self.addRule = rule[self.rtype]
  self.addTask = task[self.ttype]
  self.schedule = schedule[self.rtype]
  self.execute = execute[self.ttype]
end

function rule.SINGLE(obj, func, flag)
  if (obj.rules[1]) then error("Rule configured", 2) end
  if (flag == nil or flag == true) then
    obj.rules[1] = func
  elseif (flag == false) then
    obj.rules[1] = function(info) return (not func(info)) end
  else
    GIWUtil.colorText("Invalid arguments", colors.red)
  end
end

function rule.AND(obj, func, flag)
  if (flag == nil or flag == true) then
    table.insert(obj.rules, func)
  elseif (flag == false) then
    table.insert(obj.rules, function(info) return (not func(info)) end)
  else
    GIWUtil.colorText("Invalid arguments", colors.red)
  end
end

function rule.OR(obj, func, flag)
  rule.AND(obj, func, flag)
end

function rule.WEIGHT(obj, func, weight, flag)
  if (flag == nil or flag == true) then
    local getweight = function(info)
      if (func(info)) then return weight end
      return 0
    end
    table.insert(obj.rules, getweight)
  elseif (flag == false) then
    local getweight = function(info)
      if (not func(info)) then return weight end
      return 0
    end
    table.insert(obj.rules, getweight)
  else
    GIWUtil.colorText("Invalid arguments", colors.red)
  end
end

function task.SINGLE(obj, func)
  if (obj.tasks[1]) then error("Task configured", 2) end
  obj.tasks[1] = func
end

function task.MULTI(obj, func)
  table.insert(obj.tasks, func)
end

function task.INTERRUPTER(obj, func)
  table.insert(obj.tasks, func)
end

function schedule.SINGLE(obj, info)
  return obj.rules[1](info)
end

function schedule.AND(obj, info)
  for i, func in ipairs(obj.rules) do
    if (not func(info)) then return false end
  end
  return true
end

function schedule.OR(obj, info)
  for i, func in ipairs(obj.rules) do
    if (func(info)) then return true end
  end
  return false
end

function schedule.WEIGHT(obj, info)
  local weight = 0
  for i, func in ipairs(obj.rules) do
    weight = weight + func(info)
  end
  return (weight >= 1)
end

function execute.SINGLE(obj, info)
  obj.tasks[1](info)
end

function execute.MULTI(obj, info)
  local index = info.nexti or 1
  for i = index, #obj.tasks do
    --info:saveLog()
    obj.tasks[i](info)
    info.nexti = i + 1
    if (kflag) then
      kflag = nil
      break
    end
  end
  info.nexti = nil
end

function execute.INTERRUPTER(obj, info)
  local index = info.nexti or 1
  for i = index, #obj.tasks do
    if (obj:schedule(info) and not kflag) then
      --info:saveLog()
      obj.tasks[i](info)
      info.nexti = i + 1
    else
      kflag = nil
      break
    end
  end
  info.nexti = nil
end

function taskKill()
  kflag = true
end
