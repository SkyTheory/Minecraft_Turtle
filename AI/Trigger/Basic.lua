-- version = 1.00

function notEmptySlot(info)
  return (not SlotManager.getFirstEmptySlot())
end

function needFuel(info)
  if (not info.map) then return false end
  local need = info.map:needFuelLevel2D() + info.map.maxY - info.map.minY
  return FuelManager.hasFuel(need)
end

function dummyT(info)
  return true
end

function dummyF(info)
  return false
end

------------

function chain(obj)
  return function(info)
    local prev = info.prevEvent
    local kb = KnowledgeBase.getList()
    return (kb[prev.state][prev.index] == obj)
  end
end

function reverse(t)
  return function(info)
    return (not t(info))
  end
end

function hasNotKey(...)
  local index = GIWUtil.formatIndex(...)
  return function(info)
    return (GIWUtil.getByIndex(info, index) == nil)
  end
end
