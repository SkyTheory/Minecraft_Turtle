version = "1.01"

dependency.require("GIWUtil", "ConfigHandler", "PeripheralManager")
dependency.after("GIWUtil", "ConfigHandler", "PeripheralManager")
dependency.before("TurtleEx")

local digFn = {}
local inspectFn = {}
local fortuneDig = {}
local silktouchDig = {}

local fortune = PeripheralManager.getMoreTurtlesExtension("Fortune")
local silktouch = PeripheralManager.getMoreTurtlesExtension("SilkTouch")

local configPath = "DigExtention_config"
local config

function init()
  setFunctions()
  loadConfig()
end

function setFunctions()
  digFn.FORWARD = turtle.dig
  digFn.UP = turtle.digUp
  digFn.DOWN = turtle.digDown
  inspectFn.FORWARD = turtle.inspect
  inspectFn.UP = turtle.inspectUp
  inspectFn.DOWN = turtle.inspectDown
  if (fortune ~= nil) then
    fortuneDig.FORWARD = fortune.dig
    fortuneDig.UP = fortune.digUp
    fortuneDig.DOWN = fortune.digDown
  end
  if (silktouch ~= nil) then
    silktouchDig.FORWARD = silktouch.dig
    silktouchDig.UP = silktouch.digUp
    silktouchDig.DOWN = silktouch.digDown
  end
end

function loadConfig()
  local file = ConfigHandler:instance(configPath)
  if (not file:exists()) then createConfigFile(file) end
  file:open("r")
  config = file:loadDataList()
  file:close()
end

function createConfigFile(file)
  file:open("w")
  file:writeString("@Protect setting")
  file:writeString("")
  file:writeData("Protect", {name = "minecraft:chest"})
  file:writeData("Protect", {name = "minecraft:trapped_chest"})
  file:writeData("Protect", {name = "minecraft:ender_chest"})
  file:writeData("Protect", {name = "minecraft:mob_spawner"})
  file:writeData("Protect", {name = "minecraft:white_shulker_box"})
  file:writeData("Protect", {name = "minecraft:orange_shulker_box"})
  file:writeData("Protect", {name = "minecraft:magenta_shulker_box"})
  file:writeData("Protect", {name = "minecraft:light_blue_shulker_box"})
  file:writeData("Protect", {name = "minecraft:yellow_shulker_box"})
  file:writeData("Protect", {name = "minecraft:lime_shulker_box"})
  file:writeData("Protect", {name = "minecraft:pink_shulker_box"})
  file:writeData("Protect", {name = "minecraft:gray_shulker_box"})
  file:writeData("Protect", {name = "minecraft:silver_shulker_box"})
  file:writeData("Protect", {name = "minecraft:cyan_shulker_box"})
  file:writeData("Protect", {name = "minecraft:purple_shulker_box"})
  file:writeData("Protect", {name = "minecraft:blue_shulker_box"})
  file:writeData("Protect", {name = "minecraft:brown_shulker_box"})
  file:writeData("Protect", {name = "minecraft:green_shulker_box"})
  file:writeData("Protect", {name = "minecraft:red_shulker_box"})
  file:writeData("Protect", {name = "minecraft:black_shulker_box"})
  file:writeData("Protect", {name = "computercraft:computer"})
  file:writeData("Protect", {name = "computercraft:command_computer"})
  file:writeData("Protect", {name = "computercraft:turtle"})
  file:writeData("Protect", {name = "computercraft:turtle_advanced"})
  file:writeData("Protect", {name = "computercraft:cable"})
  file:writeData("Protect", {name = "computercraft:peripheral"})
  file:writeString("")
  file:writeString("@Fortune setting")
  file:writeString("")
  file:writeData("Fortune", {name = "minecraft:diamond_ore"})
  file:writeData("Fortune", {name = "minecraft:emerald_ore"})
  file:writeData("Fortune", {name = "minecraft:glowstone"})
  file:writeData("Fortune", {name = "minecraft:lapis_ore"})
  file:writeData("Fortune", {name = "minecraft:melon_block"})
  file:writeData("Fortune", {name = "minecraft:redstone_ore"})
  file:writeData("Fortune", {name = "minecraft:sea_lantern"})
  file:writeData("Fortune", {name = "minecraft:quartz_ore"})
  file:writeString("")
  file:writeString("@Silk touch setting")
  file:writeString("")
  file:writeData("SilkTouch", {name = "minecraft:bookshelf"})
  file:writeData("SilkTouch", {name = "minecraft:diamond_ore"})
  file:writeData("SilkTouch", {name = "minecraft:emerald_ore"})
  file:writeData("SilkTouch", {name = "minecraft:glass"})
  file:writeData("SilkTouch", {name = "minecraft:stained_glass"})
  file:writeData("SilkTouch", {name = "minecraft:glass_pane"})
  file:writeData("SilkTouch", {name = "minecraft:stained_glass_pane"})
  file:writeData("SilkTouch", {name = "minecraft:glowstone"})
  file:writeData("SilkTouch", {name = "minecraft:lapis_ore"})
  file:writeData("SilkTouch", {name = "minecraft:melon_block"})
  file:writeData("SilkTouch", {name = "minecraft:redstone_ore"})
  file:writeData("SilkTouch", {name = "minecraft:sea_lantern"})
  file:writeData("SilkTouch", {name = "minecraft:quartz_ore"})
  file:close()
end

function digEx(dir)
  local flag, data = inspectFn[dir]()
  if (not flag) then return false, "Nothing to dig here" end
  if (isProtect(data)) then return false, "Protected block detected" end
  if (fortune ~= nil and isFortune(data)) then return fortuneDig[dir]() end
  if (silktouch ~= nil and isSilkTouch(data)) then return silktouchDig[dir]() end
  return digFn[dir]()
end

function dig()
  return digEx("FORWARD")
end

function digUp()
  return digEx("UP")
end

function digDown()
  return digEx("DOWN")
end

function isProtect(data)
  for i, var in ipairs(config.Protect) do
    if (GIWUtil.isIdentical(var, data, "auto")) then
      return true
    end
  end
end

function isFortune(data)
  for i, var in ipairs(config.Fortune) do
    if (GIWUtil.isIdentical(var, data, "auto")) then
      return true
    end
  end
end

function isSilkTouch(data)
  for i, var in ipairs(config.SilkTouch) do
    if (GIWUtil.isIdentical(var, data, "auto")) then
      return true
    end
  end
end

init()
