version = 1.02

dependency.require()
dependency.after()
dependency.before("Map")

function constructor(self, x, y, z, s, disp)
  self.x = x
  self.y = y
  self.z = z
  self.state = s
  self.display = disp
end

function setValue(self, k, v)
  self[k] = v
end
