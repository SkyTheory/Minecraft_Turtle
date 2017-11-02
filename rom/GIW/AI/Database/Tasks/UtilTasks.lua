version = 1.00

function saveLog()
  return function(info)
    info:saveLog()
  end
end

function loadConfig(path)
  return function(info)
    local file = ConfigHandler:instance(path)
    file:open("r")
    info.config = file:loadDataList()
    file:close()
  end
end

function message(index)
  return function(info)
    print(info.config[index][1])
  end
end

function waitForKey()
  return function(info)
    os.pullEvent("key")
  end
end

function sleep(time)
  return function(info)
    os.sleep(time)
  end
end

function sleepI(index)
  return function(info)
    os.sleep(GIWUtil.getByIndex(info.fields, index))
  end
end

function selectNumber(sname, ctype, index)
  return function(info)
    local num = SelectorUtil.selectNumber(sname, ctype)
    GIWUtil.setByIndex(info.fields, index, num)
  end
end

function saveCoord()
  return function(info)
    info.save = GIWUtil.copy(info.coord.fields)
  end
end

function toConfigPos(index)
  return function(info)
    local ty = info.config[index][1][1]
    while (info.coord.y ~= ty) do
      if (info.coord.y > ty) then
        TurtleEx.move("DOWN")
      end
      if (info.coord.y < ty) then
        TurtleEx.move("UP")
      end
    end
    local tf = info.config[index][1][2]
    info.save = info.save or {}
    info.save.next = TurtleEx.rotate(tf)
  end
end

function moveBack()
  return function(info)
    if (info.coord.y > info.save.y) then
      TurtleEx.move("DOWN")
    end
    if (info.coord.y < info.save.y) then
      TurtleEx.move("UP")
    end
    TurtleEx.turn(info.save.facing)
  end
end
