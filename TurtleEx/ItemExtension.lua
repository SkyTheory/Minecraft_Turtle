local version = "1.10"

dependency.require("ItemManager")
dependency.after("ItemManager")
dependency.before()

local slotData = {}

function condenseItem(reverse)
  local key = saveSlot()
  for i = 1, 16 do
    for j = 1, i - 1 do
      local i2, j2 = i, j
      if (reverse) then
        i2 = 17 - i2
        j2 = 17 - j2
      end
      shiftItem(j2, i2, nil, true)
    end
  end
  loadSlot(key)
end

function sortItem(reverse)
  local items = {}
  local inv = {}
  -- Sort preparing
  condenseItem(reverse)
  if (ItemManager.getFirstEmptySlot() == -1) then return false end
  -- Get items data
  for i = 1, 16 do
    local detail = turtle.getItemDetail(i)
    if (detail) then
      local name = detail.name
      local damage = detail.damage
      local data = {slot = i, name = name, damage = damage}
      table.insert(items, data)
      table.insert(inv, data)
    else
      table.insert(inv, {slot = i, name = "Empty slot", damage = 0})
    end
  end
  -- Table sort
  table.sort(items, compare(reverse))
  for i = 1, #items do
    print(i)
    -- sortslot => current putting
    -- itemslot => target item in
    local sortslot = i
    local itemslot = items[sortslot].slot
    if (reverse) then sortslot = 17 - sortslot end
    if (not ItemManager.isIdenticalItem(sortslot, itemslot, "exact")) then
      if (not ItemManager.isEmptySlot(sortslot)) then
        local empty
        if (not reverse) then
          empty = ItemManager.getLastEmptySlot()
        else
          empty = ItemManager.getFirstEmptySlot()
        end
        if (empty == -1) then return false end
        if (shiftItem(empty, sortslot, nil, true)) then
          inv[empty], inv[sortslot] = inv[sortslot], inv[empty]
          inv[empty].slot = empty
          inv[sortslot].slot = sortslot
        else
          return false
        end
      end
      if (shiftItem(sortslot, itemslot, nil, true)) then
        inv[sortslot], inv[itemslot] = inv[itemslot], inv[sortslot]
        inv[sortslot].slot = sortslot
        inv[itemslot].slot = itemslot
      else
        return false
      end
    end
  end
  return true
end

function shiftItem(to, from, qty, disregard)
  if (not canShift(to, from, qty)) then return false end
  local fromSlot = from or turtle.getSelectedSlot()
  local key
  if (not disregard) then
    key = saveSlot()
  end
  local itemCount = turtle.getItemCount(fromSlot)
  if (turtle.getSelectedSlot() ~= fromSlot) then
    turtle.select(fromSlot)
  end
  if (qty) then
    turtle.transferTo(to, qty)
  else
    turtle.transferTo(to)
  end
  if (key) then
    loadSlot(key)
  end
  return turtle.getItemCount(fromSlot) ~= itemCount
end

function saveSlot(slot)
  local save = slot or turtle.getSelectedSlot()
  table.insert(slotData, save)
  return #slotData
end

function loadSlot(key)
  local load = key or #slotData
  turtle.select(slotData[load])
end

function canShift(to, from, qty)
  local quantity = qty or 1
  -- No items
  if (turtle.getItemCount(from) == 0) then return false end
  -- Space shortage
  if (turtle.getItemSpace(to) < quantity) then return false end
  -- Empty slot
  if (turtle.getItemCount(to) == 0) then return true end
  -- Identical items
  if (ItemManager.isIdenticalItem(to, from, "exact")) then return true end
  -- Differemt items
  return false
end

function compare(reverse)
  return function(data1, data2)
    if (data1.name == data2.name) then
      if (data1.damage == data2.damage) then
        if (reverse) then
          return (data1.slot > data2.slot)
        else
          return (data1.slot < data2.slot)
        end
      else
        return (data1.damage < data2.damage)
      end
    end
    return (data1.name < data2.name)
  end
end
