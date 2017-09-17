version = "1.00"

dependency.require("Coordinate")
dependency.after("Coordinate")
dependency.before("turtleEx")

local coord = Coordinate.getCoord()

function turnTo(f)
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

function turnArround()
  return turtle.turnRight() and turtle.turnRight()
end

function turnNorth()
  return turnTo("NORTH")
end

function turnEast()
  return turnTo("EAST")
end

function turnSouth()
  return turnTo("SOUTH")
end

function turnWest()
  return turnTo("WEST")
end
