version = "1.20"

dependency.require("GIWUtil")
dependency.after("GIWUtil")
dependency.before()

local preEventList = {}
local postEventList = {}
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
    local args = {preEvent(rawid, {...})}
    local tbl = {func(unpack(args))}
    postEvent(rawid, unpack(tbl))
    return unpack(tbl)
  end
  local id = tostring(rfunction)
  preEventList[rawid] = {}
  postEventList[rawid] = {}
  eventStorage[id] = rfunction
  eventKeys[id] = rawid
  return rfunction
end

function preEvent(id, ...)
  local args = {...}
  for k, v in ipairs(preEventList[id]) do
    args = {v(unpack(args))}
  end
end

function postEvent(id, ...)
  for k, v in ipairs(postEventList[id]) do
    v(...)
  end
end

function addPreEvent(func, event)
  if (type(func) ~= "function") then error("addEvent: Invalid value") end
  if (type(event) ~= "function") then error("addEvent: Invalid value") end
  local id = tostring(func)
  local rid = eventKeys[id]
  if (rid == nil) then
    error("addEvent: Event undefined")
  end
  table.insert(preEventList[rid], event)
end

function addPostEvent(func, event)
  if (type(func) ~= "function") then error("addEvent: Invalid value") end
  if (type(event) ~= "function") then error("addEvent: Invalid value") end
  local id = tostring(func)
  local rid = eventKeys[id]
  if (rid == nil) then
    error("addEvent: Event undefined")
  end
  table.insert(postEventList[rid], event)
end

init()
