version = "2.01"

dependency.require("Coordinate", "MoveEvent")
dependency.after("Coordinate", "MoveEvent")
dependency.before()

function constructor(self, w, d, h, f)
  self.width = w or 0
  self.depth = d or 0
  self.height = h or 0
  self.facing = f or "NORTH"
end

function getCoord(self)
  local coord = {}
  coord.width = self:getWidth()
  coord.depth = self:getDepth()
  coord.height = self:getHeight()
  coord.facing = self:getFacing()
  return coord
end

function getWidth(self)
  return Coordinate.getCoord().width + self.width
end

function getDepth(self)
  return Coordinate.getCoord().depth + self.depth
end

function getHeight(self)
  return Coordinate.getCoord().height + self.height
end

function getFacing(self)
  return Coordinate.synthesize(Coordinate.getCoord().facing, self.facing)
end

function outputCoord(self)
  print(getCoord(self).width, getCoord(self).depth, getCoord(self).height, getCoord(self).facing)
end
