version = 1.01

function detect(key)
  return function(info) return TurtleEx.detect(key) end
end

function inspect(key)
  return function(info) return TurtleEx.inspect(key) end
end

function compare(key)
  return function(info) return TurtleEx.compare(key) end
end

function inspectCompare(key, index, mode)
  return function(info)
    local flag, data1 = TurtleEx.inspect(key)
    local data2 = GIWUtil.getByIndex(info.fields, index)
    return Inventory.isIdenticalItem(data1, data2, mode)
  end
end

function isLiquidSource(key)
  return function(info)
    local flag, data = TurtleEx.inspect(key)
    if (flag) then
      if (not TurtleEx.detect(key) and data.metadata == 0) then return true end
    end
    return false end
end
