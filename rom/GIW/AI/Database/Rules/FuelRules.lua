version = 1.01

function hasFuel()
  return function(info)
    return Inventory.hasFuelByRange(info.range)
  end
end

function checkAndConsume()
  return function(info)
    return Inventory.chargeFuel(Inventory.getFuelCount(info.range))
  end
end

function hasFuelItem()
  return function(info)
    return Inventory.switchFuel()
  end
end
