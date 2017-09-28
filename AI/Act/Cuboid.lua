-- version = 1.00

function setRange(info)
  local width
  local depth
  repeat
    term.clearLine()
    io.write("Width: ")
    width = io.read()
    term.scroll(-1)
  until(tonumber(width) and tonumber(width) > 0)
  term.scroll(1)
  repeat
    term.clearLine()
    io.write("Depth: ")
    depth = io.read()
    term.scroll(-1)
  until(tonumber(depth) and tonumber(depth) > 0)
  term.scroll(1)
  width = GIWUtil.fixRange(width)
  depth = - GIWUtil.fixRange(depth)
  info.range = {width = width, depth = depth}
  info.map:extend(width, 0, depth)
end
