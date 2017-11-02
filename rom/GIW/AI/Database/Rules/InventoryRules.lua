version = 1.11

function hasEmptySlot(info)
  return function(info)
    return (Inventory.getFirstEmptySlot() ~= nil)
  end
end

function hasEmptySlotCount(num)
  return function(info)
    return (Inventory.getEmptySlotCount() >= num)
  end
end

function isEmptySlot(slot)
  return function(info)
    return (Inventory.isEmptySlot(slot))
  end
end

function hasItem(name, c)
  local count = c or 1
  return function(info)
    return (Inventory.getItemCountAll(name) >= count)
  end
end

function hasItemI(index, c)
  local count = c or 1
  return function(info)
    local name = GIWUtil.getByIndex(info.fields, index)
    return (Inventory.getItemCountAll(name) >= count)
  end
end

function hasItemCI(name, index)
  return function(info)
    local count = GIWUtil.getByIndex(info.fields, index)
    return (Inventory.getItemCountAll(name) >= count)
  end
end
