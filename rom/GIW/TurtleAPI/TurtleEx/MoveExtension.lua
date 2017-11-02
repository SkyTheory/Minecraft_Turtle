version = "1.01"

dependency.require("DigExtension", "AttackExtension")
dependency.after("DigExtension", "AttackExtension")
dependency.before()

local moveFn = {}
local digFn = {}
local attackFn = {}
local detectFn = {}

local excavate = true
local attackable = true

function init()
  setFunctions()
end

function setFunctions()
  moveFn.FORWARD= turtle.forward
  moveFn.UP = turtle.up
  moveFn.DOWN = turtle.down
  digFn.FORWARD = DigExtension.dig
  digFn.UP = DigExtension.digUp
  digFn.DOWN = DigExtension.digDown
  attackFn.FORWARD = AttackExtension.attack
  attackFn.UP = AttackExtension.attackUp
  attackFn.DOWN = AttackExtension.attackDown
  detectFn.FORWARD = turtle.detect
  detectFn.UP = turtle.detectUp
  detectFn.DOWN = turtle.detectDown
end

function moveEx(dir)
  local flag = false
  local err
  repeat
    if (turtle.getFuelLevel() == 0) then return false, "Out of fuel" end
    flag, err = moveFn[dir]()
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

function move()
  return moveEx("FORWARD")
end

function moveUp()
  return moveEx("UP")
end

function moveDown()
  return moveEx("DOWN")
end

function setExcavate(flag)
  if (flag == nil) then return end
  excavate = flag
end

function setAttack(flag)
  if (flag == nil) then return end
  attackable = flag
end

init()
