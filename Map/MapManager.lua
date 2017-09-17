version = "1.00"

dependency.require("Map", "AutoMap", "Location")
dependency.after("Map", "AutoMap", "Location")
dependency.before()

local locations = {}
local maps = {}

function init()
  locations.default = Location:instance(0, 0, 0, "NORTH")
  maps.default = AutoMap.getMap()
end

function newLocation(key, w, d, h, f)
  locations[key] = Location:instance(w, d, h, f)
end

function getLocation(key)
  local k = key or "default"
  return locations[k]
end

function newMap(key, w, d, h)
  maps[key] = Map:instance(w, d, h)
end

function getMap(key)
  local k = key or "default"
  return maps[k]
end

function output(minw, maxw, mind, maxd, height, lockey, mapkey)
  local location = getLocation(lockey)
  local map = getMap(mapkey)
  local w1 = minw - location.width
  local w2 = maxw - location.width
  local d1 = mind - location.depth
  local d2 = maxd - location.depth
  local h = height - location.height
  map:output(w1, w2, d1, d2, h)
end

init()
