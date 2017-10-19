version = 1.00

requireAPI("Inventory")

function hasFuel(info)
  return Inventory.hasFuelByRange(info.range)
end

function checkAndConsume(info)
  return Inventory.chargeFuel(Inventory.getFuelCount(info.range))
end

function hasFuelItem(info)
  return Inventory.switchFuel()
end
