version = "1.35"

dependency.require("GIWUtil", "TurtleEx")
dependency.after("GIWUtil", "TurtleEx")
dependency.before()

local slotData = {}
local locked = {}

function select(i)
  if (type(i) ~= "number") then return false, "Out of range" end
  if (i < 1 or i >= 17) then return false, "Out of range" end
  turtle.select(i)
  return true
end

function suck(dir, qty)
  return TurtleEx.suck(dir, qty)
end

function suckFull(dir)
  TurtleEx.suck(dir, turtle.getItemSpace())
  return (turtle.getItemSpace() == 0)
end

function isEmptySlot(s)
  local slot = s or turtle.getSelectedSlot()
  return (not turtle.getItemDetail(slot))
end

function getFirstEmptySlot()
  return getNextEmptySlot(0)
end

function getNextEmptySlot(s, reverse)
  local slot = s or turtle.getSelectedSlot()
  if (reverse) then
    slot = 17 - slot
  end
  for i = slot + 1, 16 do
    local i2 = i
    if (reverse) then i2 = 17 - i2 end
    if (isEmptySlot(i2)) then
      return i2
    end
  end
  return nil
end

function getLastEmptySlot()
  return getNextEmptySlot(17, true)
end

function getEmptySlotCount()
  local count = 0
  for i = 1, 16 do
    if (isEmptySlot(i)) then
      count = count + 1
    end
  end
  return count
end

function getFirstItem(target, mode)
  return getNextItem(target, 0, mode)
end

function getNextItem(target, s, mode, reverse)
  local slot = s or turtle.getSelectedSlot()
  if (reverse) then slot = 17 - slot end
  local var = target
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
  return nil
end

function getNextAnyItem(s, mode)
  return getNextItem(nil, s, nil, mode)
end

function getLastItem(target, mode)
  return getNextItem(target, 17, mode, true)
end

function getItemCount(...)
  return turtle.getItemCount(...)
end

function getItemCountAll(target, mode)
  local count = 0
  local var = target
  if (type(var) == "string") then
    var = {name = var}
  end
  for i = 1, 16 do
    if (target) then
      if (isIdenticalItem(var, i, mode)) then
        count = count + turtle.getItemCount(i)
      end
    else
      count = count + turtle.getItemCount(i)
    end
  end
  return count
end

function getLastAnyItem(s, mode)
  return getNextItem(nil, 17, nil, mode, true)
end

function getItemDetail(slot)
  return turtle.getItemDetail(slot)
end

function getItemName(var)
  local detail
  if (type(var) == "number") then
    detail = turtle.getItemDetail(var)
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
  local data1 = confirmItemData(var1)
  local data2 = confirmItemData(var2)
  return GIWUtil.isIdentical(data1, data2, switch)
end

function confirmItemData(var)
  local data
  if (type(var) == "number") then data = turtle.getItemDetail(var) end
  if (type(var) == "string") then data = {name = var} end
  if (type(var) == "table") then data = var end
  return data
end

function saveSlot(slot)
  local save = slot
  if (type(save) ~= "number" or save < 1 or save >= 17) then
    save = turtle.getSelectedSlot()
  end
  table.insert(slotData, save)
  return #slotData
end

function loadSlot(token)
  local load = token or #slotData
  return select(slotData[token])
end

function lock(slot)
  locked[slot] = true
end

function unlock(slot)
  locked[slot] = nil
end

function getLockedSlot()
  return locked
end
