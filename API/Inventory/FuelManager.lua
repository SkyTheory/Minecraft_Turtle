version = "1.04"

dependency.require("GIWUtil", "ConfigHandler", "ItemManager", "SlotManager")
dependency.after("GIWUtil", "ConfigHandler", "ItemManager", "SlotManager")
dependency.before()

local config
local configPath = "FuelManager_config"
local fuelMargin
local fuelDisplay
local fuelSwitch
local fuelItem
local fuelItems = {}

function init()
  loadConfig()
end

function loadConfig()
  local file = ConfigHandler:instance(configPath)
  if (not file:exists()) then createConfigFile(file) end
  file:open("r")
  config = file:loadDataList()
  fuelMargin = config.Margin[1]
  fuelDisplay = config.Display[1]
  fuelSwitch = config.Switch[1]
  fuelItems = config.Fuel
  file:close()
end

function createConfigFile(file)
  file:open("w")
  file:writeString("@Fuel margin setting")
  file:writeString("")
  file:writeData("Margin", 80)
  file:writeString("")
  file:writeString("@Displey setting")
  file:writeString("")
  file:writeData("Display", true)
  file:writeString("")
  file:writeString("@Automatic switch of fuel setting")
  file:writeString("")
  file:writeData("Switch", true)
  file:writeString("")
  file:writeString("@Fuel item settings")
  file:writeString("")
  file:writeData("Fuel", {display = "Charcoal", name = "minecraft:coal", damage =  1})
  file:writeData("Fuel", {display = "Blaze_Rod", name = "minecraft:blaze_rod"})
  file:writeData("Fuel", {display = "Block_of_Coal", name = "minecraft:coal_block"})
  file:writeData("Fuel", {display = "Coal", name = "minecraft:coal", damage =  0})
  file:writeData("Fuel", {display = "Lava", name = "minecraft:lava_bucket"})
  file:writeData("Fuel", {display = "Log", name = "minecraft:log"})
  file:writeData("Fuel", {display = "Log", name = "minecraft:log2"})
  file:close()
end

function switchFuel()
  if (not fuelSwitch) then return false end
  for i = 1, #fuelItems do
    local fuelSlot = SlotManager.getLastItem(fuelItems[i], "auto")
    if (fuelSlot) then
      setFuelItem(fuelItems[i])
      return true, fuelSlot
    end
  end
  return false
end


function setFuelItem(item)
  if (fuelDisplay and item) then
    if (not fuelItem) then
      print(string.format("Set fuel: %s", item.display))
    elseif (item.display ~= fuelItem.display) then
      print(string.format("Set fuel: %s -> %s", fuelItem.display, item.display))
    end
  end
  fuelItem = item
end

function getFuelItem()
  return fuelItem
end

function hasFuel(level)
  return (turtle.getFuelLevel() >= level + fuelMargin)
end

function hasFuelByRange(range)
  return hasFuel(getFuelCount(range))
end

function getFuelCount(range)
  local xr = math.abs(range.width)
  local zr = math.abs(range.depth)
  local farthest = xr + zr + (math.floor(xr * zr / 2))
  if (range.height == nil) then
    return farthest
  else
    local yr = math.abs(range.height)
    local farthest = farthest + (math.floor(plane * yr / 2))
    return farthest
  end
end

function refuel(q)
  local qty = q or 1
  local count = 0
  local refueled = false
  local token = SlotManager.saveSlot()
  while (qty > count) do
    local ok, slot = FuelManager.switchFuel()
    if (not ok) then break end
    turtle.select(slot)
    if (turtle.refuel(1)) then
      refueled = true
      count = count + 1
    end
  end
  SlotManager.loadSlot(token)
  return refueled
end

function chargeFuel(level)
  local token = SlotManager.saveSlot()
  while (not hasFuel(level)) do
    local ok, fuelSlot = switchFuel()
    if (not ok) then return false end
    turtle.select(fuelSlot)
    turtle.refuel(1)
    if (turtle.getItemCount(fuelSlot) == 0) then
      local thru = {}
      repeat
        local fslot
        repeat
          fslot = SlotManager.getFirstItem(fuelItem, "auto")
        until(not thru[fslot])
        if (fslot and not ItemManager.shiftItem(fslot, fuelSlot)) then
          thru[fslot] = true
        end
      until(fslot == fuelSlot or not fslot)
    end
  end
  SlotManager.loadSlot(token)
  return true
end

init()
