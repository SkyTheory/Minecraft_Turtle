-- version = 1.00

local unloadKey = "SOUTH"
local supplyKey = "EAST"

function initDCoord(info)
  initCoord(0, 0, 0, "NORTH")(info)
end

function initMap(info)
  info.map = AutoMap:instance(info.coord)
end

function moveForward(info)
  TurtleEx.move("FORWARD")
end

function moveUp(info)
  TurtleEx.move("UP")
end

function moveDown(info)
  TurtleEx.move("DOWN")
end

function moveBack(info)
  turtle.back()
end

function moveNorth(info)
  TurtleEx.turn("NORTH")
  TurtleEx.move("FORWARD")
end

function moveEast(info)
  TurtleEx.turn("EAST")
  TurtleEx.move("FORWARD")
end

function moveSouth(info)
  TurtleEx.turn("SOUTH")
  TurtleEx.move("FORWARD")
end

function moveWest(info)
  TurtleEx.turn("WEST")
  TurtleEx.move("FORWARD")
end

function turnNorth(info)
  TurtleEx.turn("NORTH")
end

function turnEast(info)
  TurtleEx.turn("EAST")
end

function turnSouth(info)
  TurtleEx.turn("SOUTH")
end

function turnWest(info)
  TurtleEx.turn("WEST")
end

function unload(info)
  local key = TurtleEx.rotate(unloadKey)
  local sw, fsl = FuelManager.switchFuel()
  local token = SlotManager.saveSlot()
  if (sw) then
    ItemManager.stackItem(false)
  end
  for i = 1, 16 do
    if (i ~= fsl) then
      turtle.select(i)
      TurtleEx.drop(key)
    end
  end
  slotManager.loadSlot(token)
end

function supply(info)
  local key = TurtleEx.rotate(supplyKey)
  local sw, fsl
  local slot
  local token = SlotManager.saveSlot()
  repeat
    repeat
      sw, fsl = FuelManager.switchFuel()
      if (sw) then
        slot = fsl
        turtle.select(fsl)
      else
        slot = SlotManager.getLastEmptySlot()
        if (not slot) then
          print("Out of fuel")
          print("Press any key to continue")
          os.pullEvent("key")
        end
      end
    until(slot)
    turtle.select(slot)
    TurtleEx.suck(key)
  until(FuelManager.switchFuel())
  slotManager.loadSlot(token)
end

------------

function initCoord(x, y, z, facing)
  return function(info)
    info.coord = Coordinate:instance(x, y, z, facing, true)
  end
end

function setState(state)
  return function(info)
    info.state = state
  end
end

function moveTo(dir)
  return function(info)
    TurtleEx.move(dir)
  end
end

function turnTo(f)
  return function(info)
    TurtleEx.turn(f)
  end
end
