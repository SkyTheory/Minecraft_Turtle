version = "1.00"

dependency.require()
dependency.after()
dependency.before("AttackExtension", "DigExtension")


function getBySide(side, filter)
  local p = peripheral.wrap(side)
  if (p ~= nil) then
    if (filter == nil or filter(p)) then
      return p
    end
  end
  return nil
end

function getByName(type, filter)
  for k, v in next, peripheral.getNames() do
    if (peripheral.getType(v) == type) then
      local p = peripheral.wrap(v)
      if (filter == nil or filter(p)) then
        return p, v
      end
    end
  end
  return nil
end

function getListByName(type, filter)
  local list = {}
  for k, v in next, peripheral.getNames() do
    if (peripheral.getType(v) == type) then
      local p = peripheral.wrap(v)
      if (filter == nil or filter(p)) then
        list[v] = p
      end
    end
  end
  return list
end

function isPresent(type, filter)
  for k, v in next, peripheral.getNames() do
    if (peripheral.getType(v) == type) then
      if (filter == nil) then return true end
      if (type(filter) == "string") then
        if (v == filter) then return true end
      end
      if (type(filter) == "function") then
        local p = peripheral.wrap(v)
        if (filter(p, v)) then return true end
      end
    end
  end
  return false
end

function getMoreTurtlesExtension(name)
  return getByName("MoreTurtles", filterMT(name))
end

function filterMT(name)
  return function(p) return (p.getName() == name) end
end
