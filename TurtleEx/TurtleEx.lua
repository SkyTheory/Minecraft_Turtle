version = "2.21"

dependency.require("DigExtension", "AttackExtension", "turnExtension")
dependency.after("DigExtension", "AttackExtension", "turnExtension")
dependency.before()

local moveFn = {}
local turnFn = {}
local digFn = {}
local attackFn = {}
local detectFn = {}
local inspectFn = {}
local suckFn = {}
local dropFn = {}
local placeFn = {}

local excavate = true
local attackable = true

function init()
  setFunctions()
end

function setFunctions()
  moveFn.FORWARD = turtle.forward
  moveFn.UP = turtle.up
  moveFn.DOWN = turtle.down
  turnFn.RIGHT = turtle.turnRight
  turnFn.LEFT = turtle.turnLeft
  turnFn.BACK = turnExtension.turnArround
  turnFn.NORTH = turnExtension.turnNorth
  turnFn.EAST = turnExtension.turnEast
  turnFn.SOUTH = turnExtension.turnSouth
  turnFn.WEST = turnExtension.turnWest
  digFn.FORWARD = DigExtension.dig
  digFn.UP = DigExtension.digUp
  digFn.DOWN = DigExtension.digDown
  attackFn.FORWARD = AttackExtension.attack
  attackFn.UP = AttackExtension.attackUp
  attackFn.DOWN = AttackExtension.attackDown
  detectFn.FORWARD = turtle.detect
  detectFn.UP = turtle.detectUp
  detectFn.DOWN = turtle.detectDown
  inspectFn.FORWARD = turtle.inspect
  inspectFn.UP = turtle.inspectUp
  inspectFn.DOWN = turtle.inspectDown
  suckFn.FORWARD = turtle.suck
  suckFn.UP = turtle.suckUp
  suckFn.DOWN = turtle.suckDown
  dropFn.FORWARD = turtle.drop
  dropFn.UP = turtle.dropUp
  dropFn.DOWN = turtle.dropDown
  placeFn.FORWARD = turtle.place
  placeFn.UP = turtle.placeUp
  placeFn.DOWN = turtle.placeDown
end

function setExcavate(flag)
  excavate = flag
end

function setAttack(flag)
  attackable = flag
end

function move(dir)
  local flag = false
  repeat
    if (turtle.getFuelLevel() == 0) then break end
    flag, err = go(dir)
    if (err == "Too high to move") then return false, err end
    if (err == "Too low to move") then return false, err end
    if (not flag) then
      if (detectFn[dir]) then
        -- block
        if (not excavate) then return false, "Collision with block" end
        local dflag, derr = digFn[dir]()
        if (not dflag) then return false, derr end
      else
        -- mob
        if (not attackable) then return false, "Colision with mob" end
        attackFn[dir]()
      end
    end
  until (flag)
  return true
end

function rotate(key)
  if (key == "UP" or key == "DOWN") then
    return key
  else
    turn(key)
    return "FORWARD"
  end
end

function go(dir)
  return moveFn[dir]()
end

function turn(dir)
  turnFn[dir]()
end

function dig(dir)
  return digFn[dir]()
end

function detect(dir)
  return detectFn[dir]()
end

function inspect(dir)
  return inspectFn[dir]()
end

function suck(dir, qty)
  return suckFn[dir](qty)
end

function drop(dir, qty)
  return dropFn[dir](qty)
end

function place(dir)
  return placeFn[dir]()
end

function select()
  return turtle.select()
end

function getFuelLevet()
  return turtle.getFuelLevel()
end

init()
