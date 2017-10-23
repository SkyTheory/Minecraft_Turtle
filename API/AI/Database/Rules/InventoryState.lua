version = 1.01

requireAPI("Inventory")

function hasEmptySlot(info)
  return (Inventory.getFirstEmptySlot() ~= nil)
end

function hasEmptySlotCount(num)
  return function(info)
    return (Inventory.getEmptySlotCount() >= num)
  end
end
