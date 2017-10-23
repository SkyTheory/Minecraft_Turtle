version = 1.01

requireAPI("TurtleEx", "Inventory", "ConfigHandler")

local config

function condense(flag)
  return function(info)
    Inventory.condenseItem(flag)
  end
end

function unload(path)
  if (not config) then
    if (not path) then
    error("config path undefined")
    end
    loadConfig(path)
  end
  return function(info)
    Inventory.condenseItem(false)
    local switch, slot = Inventory.switchFuel()
    local dir = TurtleEx.rotate(config.Unload[1])
    for i = 1, 16 do
      if (i ~= slot) then
        if (turtle.getItemCount(i) ~= 0) then
          Inventory.select(i)
          local flag
          repeat
            flag = validate((TurtleEx.detect(dir) and TurtleEx.drop(dir)), "Unable to unload item")
          until(flag)
        end
      end
    end
    Inventory.select(1)
  end
end

function supply(path)
  if (not config) then
    if (not path) then
    error("config path undefined")
    end
    loadConfig(path)
  end
  return function(info)
    Inventory.condenseItem(false)
    local dir = TurtleEx.rotate(config.Supply[1])
    repeat
      selectFuelSlot()
      Inventory.suckFull(dir)
    until(validate(Inventory.chargeFuel(Inventory.getFuelCount(info.range) * 2), "Unable to supply fuel"))
    Inventory.suckFull(dir)
    Inventory.select(1)
  end
end

function dispose(path)
  if (not config) then
    if (not path) then
    error("config path undefined")
    end
    loadConfig(path)
  end
  return function(info)
    Inventory.condenseItem(false)
    local dir
    local taflag
    if (not TurtleEx.detect("FORWARD")) then dir = "FORWARD" end
    if (not TurtleEx.detect("UP")) then dir = "UP" end
    if (not TurtleEx.detect("DOWN")) then dir = "DOWN" end
    if (not dir) then
      TurtleEx.turn("BACK")
      if (not TurtleEx.detect("FORWARD")) then dir = "FORWARD" end
      taflag = true
    end
    for i = 1, #config.Disposable do
      local dslot
      repeat
        dslot = Inventory.getFirstItem(config.Disposable[i], "auto")
        if (dslot) then
          Inventory.select(dslot)
          TurtleEx.drop(dir)
        end
      until(not dslot)
    end
    if (taflag) then
      TurtleEx.turn("BACK")
    end
  end
end

--------

function selectFuelSlot()
  local sf, slot = Inventory.switchFuel()
  if (sf) then
    Inventory.select(slot)
  else
    repeat
      slot = Inventory.getLastEmptySlot()
      validate((slot ~= nil), "Unable to supply fuel")
    until(slot)
    Inventory.select(slot)
  end
end

function validate(flag, msg)
  if (not flag) then
    print(msg)
    print("Press any key to continue")
    os.pullEvent("key")
  end
  return flag
end

function loadConfig(path)
  local file = ConfigHandler:instance(path)
  if (not file:exists()) then createConfigFile(file) end
  file:open("r")
  config = file:loadDataList()
  file:close()
end

function createConfigFile(file)
  file:open("w")
  file:writeString("@Chest orientations")
  file:writeString("")
  file:writeData("Unload", "SOUTH")
  file:writeData("Supply", "EAST")
  file:writeString("@Disposable item settings")
  file:writeString("")
  file:writeData("Disposable", {name = "minecraft:cobblestone"})
  file:writeData("Disposable", {name = "minecraft:stone"})
  file:writeData("Disposable", {name = "minecraft:dirt"})
  file:writeData("Disposable", {name = "minecraft:gravel"})
  file:close()
end
