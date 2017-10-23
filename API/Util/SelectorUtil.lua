version = "1.00"

dependency.require()
dependency.after()
dependency.before()

local pad = "  "
local arrow = "->"
local range = 5

function selector(sname, list)
  if (#list == 0) then
    error("Invalid list")
  end
  local p1, p2 = term.getCursorPos()
  local selected = 1
  local selection
  repeat
    print("Please select", sname)
    local imin = math.max(selected - 1, 1)
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
      term.setCursorPos(cx, cy - (imax - imin + 2))
    end
  until(selection)
  return list[selection]
end
