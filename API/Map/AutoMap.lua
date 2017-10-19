version = "1.20"

dependency.require("Map", "AutoMapEvent")
dependency.after("Map")
dependency.before("AutoMapEvent")

extends("Map")

function constructor(self, coord)
  super.constructor(self, coord.x, coord.y, coord.z)
  AutoMapEvent.registerMap(self, coord)
end

function reload(self, coord)
  AutoMapEvent.registerMap(self, coord)
end
