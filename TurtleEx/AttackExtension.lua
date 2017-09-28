version = "1.02"

dependency.require("GIWUtil", "ConfigHandler", "PeripheralManager")
dependency.after("GIWUtil", "ConfigHandler", "PerioheralManager")
dependency.before("TurtleEx")

local attackFn = {}
local lootingAttackFn = {}

local looting = PeripheralManager.getMoreTurtlesExtension("Looting")

local lootingAttack = true

local configPath = "AttackExtention_config"
local config

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
  local file = ConfigHandler:instance(configPath)
  if (not file:exists()) then createConfigFile(file) end
  file:open("r")
  config = file:loadData()
  threshold = config.Threshold
  file:close()
end

function createConfigFile(file)
  file:open("w")
  file:writeString("@Fuel threshold setting")
  file:writeString("")
  file:writeData("Threshold", 0)
  file:close()
end

function setEnchant(flag)
  lootingAttack = flag
end

function attackEx(dir)
  if (looting ~= nil and lootingAttack) then
    local fuelLevel = turtle.getFuelLevel()
    local threshold = tonumber(config.Threshold) or 0
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
