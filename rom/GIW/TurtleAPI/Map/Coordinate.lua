version = "1.40"

dependency.require("GIWUtil", "MoveEvent")
dependency.after("GIWUtil", "EventHandler", "TurnExtension", "MoveEvent")
dependency.before()

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
local orient = {}

function constructor(self, x, y, z, f, link)
  self.x = x
  self.y = y
  self.z = z
  self.facing = f
  if (link) then
    if (TurnExtension) then
      TurnExtension.linkCoord(self)
    end
  end
  MoveEvent.linkCoord(self)
end

function reload(self, x, y, z, f)
  self.x = x or self.x
  self.y = y or self.y
  self.z = z or self.z
  self.facing = f or self.facing
  if (TurnExtension) then
    TurnExtension.linkCoord(self)
  end
  MoveEvent.linkCoord(self)
end

function update(self, key)
  updateCoord[key](self)
end

function outputCoord(self)
  print(self.x, self.y, self.z, self.facing)
end

-- Coordinate update

function updateCoord.FORWARD(coord)
  updateCoord[coord.facing](coord)
end

function updateCoord.BACK(coord)
  updateCoord[synthesize(coord.facing, 2)](coord)
end

function updateCoord.UP(coord)
  coord.y = coord.y + 1
end

function updateCoord.DOWN(coord)
  coord.y = coord.y - 1
end

function updateCoord.RIGHT(coord)
  coord.facing = synthesize(coord.facing, 1)
end

function updateCoord.LEFT(coord)
  coord.facing = synthesize(coord.facing, -1)
end

function updateCoord.NORTH(coord)
  -- Negative Z
  coord.z = coord.z - 1
end

function updateCoord.EAST(coord)
  -- Positive X
  coord.x = coord.x + 1
end

function updateCoord.SOUTH(coord)
  -- Positive Z
  coord.z = coord.z + 1
end

function updateCoord.WEST(coord)
  -- Negative X
  coord.x = coord.x - 1
end

function updateCoord.TURNNORTH(coord)
  coord.facing = "NORTH"
end

function updateCoord.TURNEAST(coord)
  coord.facing = "EAST"
end

function updateCoord.TURNSOUTH(coord)
  coord.facing = "SOUTH"
end

function updateCoord.TURNWEST(coord)
  coord.facing = "WEST"
end

function getUpdateFunctions()
  return updateCoord
end

-- Util

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

function subtract(f1, f2)
  local s1 = fnum[f1] or f1 or 0
  local s2 = fnum[f2] or f2 or 0
  return numtof(s1 - s2)
end

function getNextCoord(coord, ...)
  local args = {...}
  local keys = {}
  local prevkey = "FORWARD"
  for i, v in ipairs(args) do
    if (type(v) == "string") then
      table.insert(keys, v)
      prevkey = v
    end
    if (type(v) == "number") then
      for i = 1, v do
        table.insert(keys, prevkey)
      end
    end
  end
  local nextCoord = {}
  nextCoord.x = coord.x
  nextCoord.y = coord.y
  nextCoord.z = coord.z
  nextCoord.facing = coord.facing
  for i, var in ipairs(keys) do
    updateCoord[var](nextCoord)
  end
  return nextCoord
end
