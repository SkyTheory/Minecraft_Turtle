version = "1.01"

dependency.require("GIWUtil", "FileHandler", "PeripheralManager")
dependency.after("GIWUtil", "FileHandler", "PerioheralManager")
dependency.before("TurtleEx")

local configPath = "/config/AttackExtention_config"
local config

local looting = PeripheralManager.getMoreTurtlesExtension("Looting")

local attackFn = {}
local lootingAttackFn = {}

local lootingAttack = false

function init()
  setFunctions()
  loadConfig()
end

function setFunctions()
  attackFn.FORWARD = turtle.attack
  attackFn.UP = turtle.attackUp
  attackFn.DOWN = turtle.attackDown
  if (looting ~= nil) then
    lootingAttackFn.FORWARD = looting.dig
    lootingAttackFn.UP = looting.digUp
    lootingAttackFn.DOWN = looting.digDown
  end
end

function loadConfig()
  local file = FileHandler:instance(configPath)
  if (not file:exists()) then createConfigFile(file) end
  file:open("r")
  config = file:loadDataList()
  file:close()
end

function createConfigFile(file)
  file:open("w")
  file:writeString("@Fuel threshold setting")
  file:writeString("")
  file:writeData("threshold", 0)
  file:close()
end

function setEnchant(flag)
  lootingAttack = flag
end

function attackEx(dir)
  if (looting ~= nil and lootingAttack) then
    local fuelLevel = turtle.getFuelLevel()
    local threshold = tonumber(config.threshold) or 0
    if (threshold < fuelLevel) then
      return lootingAttackFn[dir]()
    end
  end
  return attackFn[dir]()
end

function attack()
  return attackEx("FORWARD")
end

function attackUp()
  return attackEx("UP")
end

function attackDown()
  return attackEx("DOWN")
end

init()
