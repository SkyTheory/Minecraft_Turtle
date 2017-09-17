version = "1.20"

dependency.require("GIWUtil", "MoveEvent")
dependency.after("GIWUtil", "EventHandler")
dependency.before("MoveEvent")

local coordinate = {}
coordinate.width = 0
coordinate.depth = 0
coordinate.height = 0
coordinate.facing = "NORTH"

local facing = {}
facing[0] = "NORTH"
facing[1] = "EAST"
facing[2] = "SOUTH"
facing[3] = "WEST"

local fnum = {}
fnum.NORTH = 0
fnum.EAST = 1
fnum.SOUTH = 2
fnum.WEST = 3

local updateCoord = {}

function updateCoord.NORTH(coord)
  coord.depth = coord.depth + 1
end

function updateCoord.EAST(coord)
  coord.width = coord.width + 1
end

function updateCoord.SOUTH(coord)
  coord.depth = coord.depth - 1
end

function updateCoord.WEST(coord)
  coord.width = coord.width - 1
end

function updateCoord.UP(coord)
  coord.height = coord.height + 1
end

function updateCoord.DOWN(coord)
  coord.height = coord.height - 1
end

function updateCoord.RIGHT(coord)
  coord.facing = synthesize(coord.facing, 1)
end

function updateCoord.LEFT(coord)
  coord.facing = synthesize(coord.facing, -1)
end

function getUpdateFunctions()
  return updateCoord
end

function ftonum(f)
  return fnum[f]
end

function numtof(num)
  num = num % 4
  return facing[num]
end

function synthesize(f1, f2)
  local s1 = fnum[f1] or f1 or 0
  local s2 = fnum[f2] or f2 or 0
  return numtof(s1 + s2)
end

function getCoord()
  return coordinate
end

function getNextCoord(dir)
  local nextCoord = GIWUtil.copy(coordinate)
  updateCoord[dir](nextCoord)
  return nextCoord
end

function outputCoord()
  print(coordinate.width, coordinate.depth, coordinate.height, coordinate.facing)
end
