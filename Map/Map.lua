version = "2.00"

dependency.require("Node")
dependency.after("Node")
dependency.before()

local defaultDisplay = "."
local undefined = "-"
local partition = "|"

function constructor(self, w, d, h)
  self.minWidth = 0
  self.minDepth = 0
  self.minHeight = 0
  self.maxWidth = 0
  self.maxDepth = 0
  self.maxHeight = 0
  self.nodes = {}
  local width = w or 0
  local depth = d or 0
  local height = h or 0
end

function setDefaultDisplay(str)
  defaultDisplay = str
end

function setUndefined(str)
  undefined = str
end

function setPartition(str)
  partition = str
end

function openNode(self, w, d, h)
  local key = makeKey(w, d, h)
  self.nodes[key] = Node:instance(w, d, h, defaultDisplay)
end

function getNode(self, w, d, h)
  local key = makeKey(w, d, h)
  return self.nodes[key]
end

function setValue(self, w, d, h, k, v)
  self:extend(w, d, h)
  local node = self:getNode(w, d, h)
  node:setValue(k, v)
end

function getValue(self, w, d, h, k)
  local node = self:getNode(w, d, h)
  if (node ~= nil) then
    return node[k]
  end
  return nil
end

function extend(self, w, d, h, force)
  if (not force and self:getNode(w, d, h) ~= nil) then return end
  local minw = math.min(self.minWidth, w)
  local mind = math.min(self.minDepth, d)
  local minh = math.min(self.minHeight, h)
  local maxw = math.max(self.maxWidth, w)
  local maxd = math.max(self.maxDepth, d)
  local maxh = math.max(self.maxHeight, h)
  for iw = minw, maxw do
    for id = mind, maxd do
      for ih = minh, maxh do
        if (self:getNode(iw, id, ih) == nil) then
          self:openNode(iw, id, ih)
        end
      end
    end
  end
  self.minWidth = minw
  self.minDepth = mind
  self.minHeight = minh
  self.maxWidth = maxw
  self.maxDepth = maxd
  self.maxHeight = maxh
end

function needFuelLevel2D(self)
  local wr = self.max.width - self.min.width
  local dr = self.max.depth - self.min.depth
  local farthest = wr + dr + (math.floor(wr * dr / 2))
  return farthest
end

function needFuelLevel3D(self)
  local hr = self.max.height - self.min.height
  local plane =  self:needFuelLevel2D()
  local farthest = plane + (math.floor(plane * hr / 2))
  return farthest
end

function output(self, minw, maxw, mind, maxd, h)
  for id = maxd, mind, -1 do
    local linet = {}
    for iw = minw, maxw do
      local box = self:getValue(iw, id, h, "display") or undefined
      table.insert(linet, box)
    end
    local line = table.concat(linet, partition)
    print(line)
  end
end

function makeKey(w, d, h)
  return string.format("W%iD%iH%i", w, d, h)
end
