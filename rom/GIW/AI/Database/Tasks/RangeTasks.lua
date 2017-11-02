version = 1.00

function init2D()
  return function(info)
    local wdir = true
    local ddir = false
    info.range = SelectorUtil.range2D(wdir, ddir)
  end
end

function init3D(hd)
  return function(info)
    local direction = hd or SelectorUtil.selector("direction", {"UP", "DOWN"})
    local wdir = true
    local ddir = false
    local hdir
    info.mine = direction
    if (direction == "UP") then
      hdir = true
      info.nextY = 1
    end
    if (direction == "DOWN") then
      hdir = false
      info.nextY = -1
    end
    info.range = SelectorUtil.range3D(wdir, ddir, hdir)
  end
end

function moveAdvance()
  return function(info)
    TurtleEx.move(info.mine)
  end
end

function moveRetreat()
  return function(info)
    if (info.mine == "UP") then
      TurtleEx.move("DOWN")
    end
    if (info.mine == "DOWN") then
      TurtleEx.move("UP")
    end
  end
end

function updateDepth()
  return function(info)
    if (info.mine == "UP") then
      info.nextY = info.nextY + 3
    end
    if (info.mine == "DOWN") then
      info.nextY = info.nextY - 3
    end
  end
end

function lastPreWork()
  return function(info)
    if (info.mine == "UP") then
      local limit = info.range.maxHeight
      if (info.nextY ~= limit) then
        for i = info.map.minX, info.map.maxX do
          for j = info.map.minZ, info.map.maxZ do
            info.map:setState(i, limit - 1, j, "undefined")
          end
        end
      end
    end
    if (info.mine == "DOWN") then
      local limit = info.range.minHeight
      if (info.nextY ~= limit) then
        for i = info.map.minX, info.map.maxX do
          for j = info.map.minZ, info.map.maxZ do
            info.map:setState(i, limit + 1, j, "undefined")
          end
        end
      end
    end
  end
end
