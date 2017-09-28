version = "2.20"

dependency.require("Node", "AutoMap")
dependency.after("Node")
dependency.before("AutoMap")

local initState = "undefined"
local undefined = " "
local partition = "/"

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

function openNode(self, x, y, z, s, disp)
  local key = makeKey(x, y, z)
  local state = s or initState
  local display = disp or undefined
  self.nodes[key] = Node:instance(w, d, h, state, display)
end

function getNode(self, x, y, z)
  local key = makeKey(x, y, z)
  return self.nodes[key]
end

function setValue(self, x, y, z, k, v)
  self:extend(x, y, z)
  local node = self:getNode(x, y, z)
  node:setValue(k, v)
end

function getValue(self, x, y, z, k)
  local node = self:getNode(x, y, z)
  if (node) then
    return node[k]
  end
  return nil
end

function extend(self, x, y, z, force)
  if (not force and self:getNode(x, y, z) ~= nil) then return end
  local minX = math.min(self.minX, x)
  local minY = math.min(self.minY, y)
  local minZ = math.min(self.minZ, z)
  local maxX = math.max(self.maxX, x)
  local maxY = math.max(self.maxY, y)
  local maxZ = math.max(self.maxZ, z)
  for ix = minX, maxX do
    for iy = minY, maxY do
      for iz = minZ, maxZ do
        if (not self:getNode(ix, iy, iz)) then
          self:openNode(ix, iy, iz)
        end
      end
    end
  end
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

function output(self, minX, maxX, minZ, maxZ, y)
  for iz = minZ, maxZ do
    local linet = {}
    for ix = minX, maxX do
      local box = self:getValue(ix, y, iz, "display") or undefined
      table.insert(linet, box)
    end
    local line = table.concat(linet, partition)
    print(line)
  end
end

function makeKey(x, y, z)
  return string.format("x%iy%iz%i", x, y, z)
end
