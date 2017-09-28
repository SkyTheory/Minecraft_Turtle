version = "1.10"

dependency.require("GIWUtil")
dependency.after("GIWUtil")
dependency.before()

local slotData = {}

function isEmptySlot(s)
  local slot = s or turtle.getSelectedSlot()
  return (not turtle.getItemDetail(slot))
end

function getFirstEmptySlot()
  return getNextEmptySlot(0)
end

function getNextEmptySlot(s, mode)
  local reverse = (mode == false)
  local slot = s
  if (reverse) then slot = 17 - slot end
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
  return getNextEmptySlot(17, false)
end

function getFirstItem(target, mode)
  return getNextItem(target, 0, mode)
end

function getNextItem(target, s, mode, rmode)
  local reverse = (rmode == false)
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
  return nil
end

function getNextAnyItem(s, mode)
  return getNextItem(nil, s, nil, mode)
end

function getLastItem(target, mode)
  return getNextItem(target, 17, mode, false)
end

function getLastAnyItem(s, mode)
  return getNextItem(nil, 17, nil, mode, false)
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
  local data1 = confirmItemData(var1)
  local data2 = confirmItemData(var2)
  return GIWUtil.isIdentical(data1, data2, switch)
end

function confirmItemData(var)
  local data
  if (type(var) == "number") then data = turtle.getItemDetail(var) end
  if (type(var) == "string") then data = {name = var, damage = 0} end
  if (type(var) == "table") then data = var end
  return data
end

function saveSlot(slot)
  local save = slot or turtle.getSelectedSlot()
  table.insert(slotData, save)
  return #slotData
end

function loadSlot(token)
  local load = token or #slotData
  turtle.select(slotData[token])
end
