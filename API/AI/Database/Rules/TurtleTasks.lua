version = 1.00

requireAPI("TurtleEx")

function detect(key)
  return function(info) return TurtleEx.detect(key) end
end

function inspect(key)
  return function(info) return TurtleEx.inspect(key) end
end

function isLiquidSource(key)
  return function(info)
    local flag, data = TurtleEx.inspect(key)
    if (flag) then
      if (not TurtleEx.detect(key) and data.metadata == 0) then return true end
    end
    return false end
end
