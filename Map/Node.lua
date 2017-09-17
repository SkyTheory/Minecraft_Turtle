version = 1.00

dependency.require()
dependency.after()
dependency.before("Map")

function constructor(self, w, d, h, d)
  self.width = w
  self.depth = d
  self.height = h
  self.display = d
end

function setValue(self, k, v)
  self[k] = v
end
