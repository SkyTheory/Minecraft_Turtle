version = 1.00

requireAPI()

function setRange2D(info)
  local width
  local depth
  local p1, p2 = term.getCursorPos()
  repeat
    term.setCursorPos(p1, p2)
    term.clearLine()
    io.write("Width: ")
    width = io.read()
  until(tonumber(width) and tonumber(width) > 0)
  p1, p2 = term.getCursorPos()
  repeat
    term.setCursorPos(p1, p2)
    term.clearLine()
    io.write("Depth: ")
    depth = io.read()
  until(tonumber(depth) and tonumber(depth) > 0)
  width = GIWUtil.fixRange(width)
  depth = - GIWUtil.fixRange(depth)
  info.range = {width = width, depth = depth}
  info.map:extend(width, 0, depth)
end

function setState(s)
  return function(info)
    info.state = s
  end
end

function setData(index, v)
  return function(info)
    GIWUtil.setByIndex(info.fields, index, v, true)
  end
end

function addData(index, v)
  return function(info)
    local var = GIWUtil.getByIndex(info.fields, index)
    GIWUtil.setByIndex(info.fields, index, var + v)
  end
end

function copyData(fromindex, toindex)
  return function(info)
    local data = GIWUtil.getByIndex(info.fields, fromindex)
    GIWUtil.setByIndex(info.fields, toindex, data, true)
  end
end

function setTemporaryData(key)
  return function(info)
    info:setTemporaryData(key)
  end
end
