version = "2.52"

dependency.require("EventHandler", "DigExtension", "MoveExtension", "Coordinate", "AutoMap", "MoveEvent")
dependency.after("EventHandler", "DigExtension", "MoveExtension", "Coordinate", "AutoMap", "MoveEvent")
dependency.before("TurtleEx")

local autoMap

local coord

function init()
  registerEvent()
end

function registerEvent()
  MoveExtension.move = EventHandler.register(MoveExtension.move)
  MoveExtension.moveUp = EventHandler.register(MoveExtension.moveUp)
  MoveExtension.moveDown = EventHandler.register(MoveExtension.moveDown)
  DigExtension.dig = EventHandler.register(DigExtension.dig)
  DigExtension.digUp = EventHandler.register(DigExtension.digUp)
  DigExtension.digDown = EventHandler.register(DigExtension.digDown)
end

function registerMap(map, coord)
  EventHandler.addPostEvent(MoveExtension.move, moveEvent(map, coord, "FORWARD"))
  EventHandler.addPostEvent(MoveExtension.moveUp, moveEvent(map, coord, "UP"))
  EventHandler.addPostEvent(MoveExtension.moveDown, moveEvent(map, coord, "DOWN"))
  EventHandler.addPostEvent(DigExtension.dig, digEvent(map, coord, "FORWARD"))
  EventHandler.addPostEvent(DigExtension.digUp, digEvent(map, coord, "UP"))
  EventHandler.addPostEvent(DigExtension.digDown, digEvent(map, coord, "DOWN"))
end

function eventState(map, coord, dir, state)
  local nc = coord:getNextCoord(dir)
  map:setState(nc.x, nc.y, nc.z, state)
end

function moveEvent(map, coord, dir)
  return function(flag, err)
    if (flag) then
      eventState(map, coord, nil, "blank")
    else
      if (err ~= "Out of fuel") then
        eventState(map, coord, dir, "obstruction")
      end
    end
  end
end

function digEvent(map, coord, dir)
  return function(flag, err)
    if (flag) then
      eventState(map, coord, dir, "blank")
    else
      if (err == "Nothing to dig here") then
        eventState(map, coord, dir, "blank")
      end
      if (err == "Unbreakable block detected" or err == "Protected block detected") then
        eventState(map, coord, dir, "obstruction")
      end
    end
  end
end

init()
