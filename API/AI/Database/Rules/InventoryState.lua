version = 1.00

requireAPI("Inventory")

function hasEmptySlot(info)
  return (Inventory.getFirstEmptySlot() ~= nil)
end
