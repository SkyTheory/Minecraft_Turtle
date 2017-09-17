local version = "1.02"

dependency.require("GIWUtil")
dependency.after("GIWUtil")
dependency.before("ItemExtension")

--[[
function positionFuel()
  if (Ariadna == nil) then return end
  local sFuelSlot = getLastItem(Ariadna.getFuel())
  if (sFuelSlot == -1) then
    Ariadna.switchFuel()
    sFuelSlot = getLastItem(Ariadna.getFuel())
  end
  if (sFuelSlot ~= -1 and sFuelSlot ~= 16) then
    local flag = shiftItem(sFuelSlot, 16)
    if (flag) then
      Ariadna.setFuelSlot(16)
      for i = 15, sFuelSlot + 1, -1 do
        if (turtle.getItemSpace(sFuelSlot) == 0) then break end
        if (turtle.getItemCount(i) ~= 0) then
          if (turtle.getItemCount(sFuelSlot) == 0 or isIdenticalItem(sFuelSlot, i, "exact")) then
            shiftItem(i, sFuelSlot)
          end
        end
      end
    end
  end
end

--]]

function isEmptySlot(s)
  local slot = s or turtle.getSelectedSlot()
  return (not turtle.getItemDetail(s))
end

function getFirstEmptySlot()
  return getNextEmptySlot(0)
end

function getNextEmptySlot(s, reverse)
  local slot = s
  if (reverse) then slot = 17 - slot end
  for i = slot + 1, 16 do
    local i2 = i
    if (reverse) then i2 = 17 - i2 end
    if (isEmptySlot(i2)) then
      return i2
    end
  end
  return -1
end

function getLastEmptySlot()
  return getNextEmptySlot(1, reverse)
end

function getFirstItem(target, mode)
  return getNextItem(target, 0)
end

function getNextItem(target, s, mode, reverse)
  if (target == nil) then return getNextAnyItem(s, reverse) end
  local slot = s or turtle.getSelectedSlot()
  if (reverse) then slot = 17 - slot end
  local var = target
  if (type(var) == "string") then
    var = {name = var}
  end
  for i = slot + 1, 16 do
    local i2 = i
    if (reverse) then i2 = 17 - i2 end
    if (target) then
      if (isIdenticalItem(var, i2, mode)) then
        return i2
      end
    else
      if (turtle.getItemCount() ~= 0) then return i2 end
    end
  end
  return -1
end

function getLastItem(target, mode)
  return getNextItem(target, 17, mode, true)
end

function getItemName(var)
  local detail
  if (type(var) == "number") then
    detail = turtle.getItemDetail(slot)
  end
  if (type(var) == "table") then
    detail = var
  end
  if (detail) then
    return detail.name
  else
    return nil
  end
end

function isIdenticalItem(var1, var2, switch)
  local tbl1
  local tbl2
  if (type(var1) == "number") then tbl1 = turtle.getItemDetail(var1) end
  if (type(var1) == "table") then tbl1 = var1 end
  if (type(var2) == "number") then tbl2 = turtle.getItemDetail(var2) end
  if (type(var2) == "table") then tbl2 = var2 end
  return GIWUtil.isIdentical(tbl1, tbl2, switch)
end
