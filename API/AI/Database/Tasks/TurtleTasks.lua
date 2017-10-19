version = 1.00

requireAPI("TurtleEx")

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
