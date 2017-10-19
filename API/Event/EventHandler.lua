version = "1.00"

dependency.require("GIWUtil")
dependency.after("GIWUtil")
dependency.before()

local eventList = {}
local eventListID = {}
local eventStorage = {}
local eventKeys = {}

function init()
  setENV("colors")
  setENV("colours")
  setENV("coroutine")
  setENV("disk")
  setENV("fs")
  setENV("gps")
  setENV("os")
  setENV("paintutils")
  setENV("parallel")
  setENV("peripheral")
  setENV("rednet")
  setENV("redstone")
  setENV("rs")
  setENV("sleep")
  setENV("term")
  setENV("textutils")
  setENV("turtle")
  setENV("vector")
  setENV("window")
end

function setENV(name)
  GIWUtil.setValue(name, GIWUtil.copy(_G[name]))
end

function register(func)
  if (type(func) ~= "function") then error("register: Invalid value") end
  local rawid = tostring(func)
  if (eventStorage[rawid] ~= nil) then return eventStorage[rawid] end
  local rfunction = function(...)
    local tbl = {func(...)}
    event(rawid, unpack(tbl))
    return unpack(tbl)
  end
  local id = tostring(rfunction)
  eventList[rawid] = {}
  eventStorage[id] = rfunction
  eventKeys[id] = rawid
  return rfunction
end

function event(id, ...)
  for k, v in next, eventList[id] do
    v(...)
  end
end

function addEvent(func, event)
  if (type(func) ~= "function") then error("addEvent: Invalid value") end
  if (type(event) ~= "function") then error("addEvent: Invalid value") end
  local id = tostring(func)
  local rid = eventKeys[id]
  if (rid == nil) then
    error("addEvent: Event undefined")
  end
  table.insert(eventList[rid], event)
end

init()
