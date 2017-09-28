version = "2.22"

dependency.require("MoveExtension", "DigExtension", "AttackExtension", "TurnExtension")
dependency.after("MoveExtension", "DigExtension", "AttackExtension", "TurnExtension")
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
local condenseFn
local shiftFn
local sortFn

function init()
  setFunctions()
end

function setFunctions()
  moveFn.FORWARD = MoveExtension.move
  moveFn.UP = MoveExtension.moveUp
  moveFn.DOWN = MoveExtension.moveDown
  moveFn.BACK = turtle.back
  turnFn.RIGHT = turtle.turnRight
  turnFn.LEFT = turtle.turnLeft
  turnFn.BACK = TurnExtension.turnArround
  turnFn.NORTH = TurnExtension.turnNorth
  turnFn.EAST = TurnExtension.turnEast
  turnFn.SOUTH = TurnExtension.turnSouth
  turnFn.WEST = TurnExtension.turnWest
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

function rotate(key)
  if (key == "UP" or key == "DOWN") then
    return key
  else
    turn(key)
    return "FORWARD"
  end
end

function move(dir)
  moveFn[dir]()
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

function getFuelLevel()
  return turtle.getFuelLevel()
end

init()
