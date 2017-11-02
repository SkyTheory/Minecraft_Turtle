version = 1.00

function requireCrafty()
  return function(info)
    if (not PeripheralManager.isPresent("workbench")) then
      GIWUtil.colorText("Crafting table required", colors.red)
      info.state = "exit"
      AIData.taskKill()
    end
  end
end

function move(key)
  return function(info) TurtleEx.move(key) end
end

function turn(key)
  return function(info) TurtleEx.turn(key) end
end

function dig(key)
  return function(info) TurtleEx.dig(key) end
end

function attack(key)
  return function(info) TurtleEx.attack(key) end
end

function suck(key, qty)
  return function(info) TurtleEx.suck(key, qty) end
end

function drop(key, qty)
  return function(info) TurtleEx.drop(key, qty) end
end

function place(key)
  return function(info) TurtleEx.place(key) end
end

function craft()
  return function(info) turtle.craft() end
end
