version = "1.03"

dependency.require()
dependency.after()
dependency.before()

local pad = "  "
local arrow = "->"
local range = 5

function selector(sname, list)
  if (type(list) ~= "table" or #list == 0) then
    error("Invalid list")
  end
  local p1, p2 = term.getCursorPos()
  local selected = 1
  local selection
  repeat
    print("Please select", sname)
    local imin = math.max(selected - math.floor(range / 2), 1)
    local imax = imin + range - 1
    if (imax > #list) then
      imin = math.max(imin - (imax - #list), 1)
      imax = #list
    end
    for i = imin, imax do
      local lpad = pad
      if (selected == i) then lpad = arrow end
      print(lpad, list[i])
    end
    repeat
      local kflag = false
      local e, keynum = os.pullEvent("key")
      local key = keys.getName(keynum)
      if (key == "enter") then
        selection = selected
        kflag = true
      end
      if (key == "up") then
        if (selected > 1) then
          selected = selected - 1
        end
        kflag = true
      end
      if (key == "down") then
        if (selected < #list) then
          selected = selected + 1
        end
        kflag = true
      end
    until(kflag)
    if (not selection) then
      local cx, cy = term.getCursorPos()
      local sety = cy - (imax - imin + 2)
      while (cy > sety) do
        term.clearLine()
        cy = cy - 1
        term.setCursorPos(cx, cy)
      end
    end
  until(selection)
  return list[selection]
end

function selectNumber(sname, ctype)
  local p1, p2 = term.getCursorPos()
  local num
  local condition = {}
  condition.all = function(num) return (num ~= nil) end
  condition.pos = function(num) return (num ~= nil and num > 0) end
  condition.poszero = function(num) return (num ~= nil and num >= 0) end
  condition.neg = function(num) return (num ~= nil and num < 0) end
  condition.negzero = function(num) return (num ~= nil and num <= 0) end
  local ccon = condition[ctype] or condition.all
  repeat
    term.setCursorPos(p1, p2)
    term.clearLine()
    io.write(string.format("%s: ", sname))
    num = tonumber(io.read())
  until(ccon(num))
  return num
end

function range2D(pw, pd)
  local range = {}
  local rwidth = selectNumber("Width", "pos")
  local rdepth = selectNumber("Depth", "pos")
  local fwidth = GIWUtil.fixRange(rwidth)
  local fdepth = GIWUtil.fixRange(rdepth)
  if (pw) then
    range.minWidth = 0
    range.maxWidth = fwidth
  else
    range.minWidth = - fwidth
    range.maxWidth = 0
  end
  if (pd) then
    range.minDepth = 0
    range.maxDepth = fdepth
  else
    range.minDepth = - fdepth
    range.maxDepth = 0
  end
  return range
end

function range3D(pw, pd, ph)
  local range = range2D(pw, pd)
  local rheight = selectNumber("Height", "pos")
  local fheight = GIWUtil.fixRange(rheight)
  if (ph) then
    range.minHeight = 0
    range.maxHeight = fheight
  else
    range.minHeight = - fheight
    range.maxHeight = 0
  end
  return range
end
