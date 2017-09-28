version = "1.01"

dependency.require()
dependency.after()
dependency.before("turtleEx")

local coord

function turnArround()
  return turtle.turnRight() and turtle.turnRight()
end

function linkCoord(c)
  coord = c
end

function turnTo(f)
  if (not coord) then
    error("Coordinate unspecified")
  end
  if (f == coord.facing) then
    return true
  end
  if (f == Coordinate.synthesize(coord.facing, 1)) then
    return turtle.turnRight()
  end
  if (f == Coordinate.synthesize(coord.facing, 2)) then
    return turtle.turnRight() and turtle.turnRight()
  end
  if (f == Coordinate.synthesize(coord.facing, 3)) then
    return turtle.turnLeft()
  end
end

function turnNorth()
  return turnTo("NORTH")
end

function turnEast(coord)
  return turnTo("EAST")
end

function turnSouth(coord)
  return turnTo("SOUTH")
end

function turnWest(coord)
  return turnTo("WEST")
end
