version = 1.00

requireAPI("Inventory")

function refuel(info)
  Inventory.chargeFuel(Inventory.getFuelCount(info.range))
end
