version = "1.10"

dependency.require("Map", "AutoMapEvent")
dependency.after("Map")
dependency.before("AutoMapEvent")

local autoMap = Map:instance()

function getMap()
  return autoMap
end
