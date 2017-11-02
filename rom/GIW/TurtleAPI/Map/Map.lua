version = "2.31"

dependency.require("AutoMap")
dependency.after()
dependency.before("AutoMap")

local partition = "/"

local display = {}
display.undefined = " "
display.obstruction = "+"
display.blank = "."

function constructor(self, x, y, z)
  local initx = x or 0
  local inity = y or 0
  local initz = z or 0
  self.minX = initx
  self.minY = inity
  self.minZ = initz
  self.maxX = initx
  self.maxY = inity
  self.maxZ = initz
  self.nodes = {}
end

function setState(self, x, y, z, s)
  self:extend(x, y, z)
  self.nodes[x] = self.nodes[x] or {}
  self.nodes[x][y] = self.nodes[x][y] or {}
  self.nodes[x][y][z] = s
end

function getState(self, x, y, z)
  if (not self.nodes[x]) then return "undefined" end
  if (not self.nodes[x][y]) then return "undefined" end
  if (not self.nodes[x][y][z]) then return "undefined" end
  return self.nodes[x][y][z]
end

function extend(self, x, y, z)
  local minX = math.min(self.minX, x)
  local minY = math.min(self.minY, y)
  local minZ = math.min(self.minZ, z)
  local maxX = math.max(self.maxX, x)
  local maxY = math.max(self.maxY, y)
  local maxZ = math.max(self.maxZ, z)
  self.minX = minX
  self.minY = minY
  self.minZ = minZ
  self.maxX = maxX
  self.maxY = maxY
  self.maxZ = maxZ
end

function needFuelLevel2D(self)
  local xr = self.maxX - self.minX
  local zr = self.maxZ - self.minZ
  local farthest = xr + zr + (math.floor(xr * zr / 2))
  return farthest
end

function needFuelLevel3D(self)
  local yr = self.maxY - self.minY
  local plane =  self:needFuelLevel2D()
  local farthest = plane + (math.floor(plane * yr / 2))
  return farthest
end

function needFuelLevelS2D(self, xSize, zSize)
  local xr = xSize or (self.maxX - self.minX)
  local zr = zSize or (self.maxZ - self.minZ)
  local farthest = xr + zr + (math.floor(xr * zr / 2))
  return farthest
end

function needFuelLevelS3D(self, xSize, ySize, zSize)
  local yr = ySize or (self.maxY - self.minY)
  local plane =  self:needFuelLevelS2D(xSize, zSize)
  local farthest = plane + (math.floor(plane * yr / 2))
  return farthest
end

function output(self, minX, maxX, minZ, maxZ, y)
  for iz = minZ, maxZ do
    local linet = {}
    for ix = minX, maxX do
      local box = display[self:getValue(ix, y, iz, "state")] or "?"
      table.insert(linet, box)
    end
    local line = table.concat(linet, partition)
    print(line)
  end
end

function makeKey(x, y, z)
  return string.format("x%iy%iz%i", x, y, z)
end
