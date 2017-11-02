version = 1.01

function refuel()
  return function(info)
    Inventory.chargeFuel(Inventory.getFuelCount(info.range))
  end
end
