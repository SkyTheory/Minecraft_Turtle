version = "1.20"

dependency.require("SlotManager")
dependency.after("SlotManager")
dependency.before()

local locked = SlotManager.getLockedSlot()

function condenseItem(reverse)
  local token = SlotManager.saveSlot()
  for i = 1, 16 do
    for j = 1, i - 1 do
      local i2, j2 = i, j
      if (reverse) then
        i2 = 17 - i2
        j2 = 17 - j2
      end
      if (not isLocked(i2, j2)) then
        shiftItem(i2, j2, nil, true)
      end
    end
  end
  SlotManager.loadSlot(token)
end

function transferFrom(from)
  local to = turtle.getSelectedSlot()
  local lock, err = isLocked(from, to)
  if (lock) then return false, err end
  local token = SlotManager.saveSlot()
  SlotManager.select(from)
  ok, err = turtle.transferTo(to)
  SlotManager.loadSlot(token)
  return ok, err
end

function transferTo(to)
  local from = turtle.getSelectedSlot()
  local lock, err = isLocked(from, to)
  if (lock) then return false, err end
  return turtle.transferTo(to)
end

function shiftItem(from, to, qty, disregard)
  local fromSlot = from or turtle.getSelectedSlot()
  local toSlot = to or turtle.getSelectedSlot()
  local itemCount = turtle.getItemCount(fromSlot)
  local key
  local token
  if (not canShift(fromSlot, toSlot, qty)) then return false end
  if (not disregard) then
    token = SlotManager.saveSlot()
  end
  if (turtle.getSelectedSlot() ~= fromSlot) then
    SlotManager.select(fromSlot)
  end
  if (qty) then
    turtle.transferTo(toSlot, qty)
  else
    turtle.transferTo(toSlot)
  end
  if (not disregard) then
    SlotManager.loadSlot(token)
  end
  if (turtle.getItemCount(from) ~= itemCount) then return true end
  return false, "Shift failed"
end

function isLocked(fromSlot, toSlot)
  if (locked[fromSlot]) then
    return true, "Transfer source is locked"
  end
  if (locked[toSlot]) then
    return true, "Transfer destination is locked"
  end
  return false
end

function sortItem(reverse)
  local token = SlotManager.saveSlot()
  local items = {}
  local inv = {}
  local lnum = {}
  -- Sort preparing
  stackItem(not reverse)
  if (not SlotManager.getFirstEmptySlot()) then
    SlotManager.loadSlot(token)
    return false, "No space"
  end
  -- Get items data
  for i = 1, 16 do
    if (locked[i]) then
      table.insert(lnum, i)
      table.insert(inv, {slot = i, lock = true})
    else
      local detail = turtle.getItemDetail(i)
      if (detail) then
        local name = detail.name
        local damage = detail.damage
        local data = {slot = i, name = name, damage = damage}
        table.insert(items, data)
        table.insert(inv, data)
      else
        table.insert(inv, {slot = i, name = "EmptySlot", damage = 0})
      end
    end
  end
  -- Table sort
  table.sort(items, compare(not reverse))
  for i, v in ipairs(lnum) do
    table.insert(items, v, {slot = v, lock = true})
  end
  for i = 1, #items do
    -- sortslot => current putting
    -- itemslot => target item in
    local sortslot = i
    local itemslot = items[sortslot].slot
    if (not items[sortslot].lock) then
      if (reverse) then sortslot = 17 - sortslot end
      if (sortslot ~= itemslot) then
        if (not SlotManager.isEmptySlot(sortslot)) then
          local empty
          if (reverse) then
            empty = SlotManager.getFirstEmptySlot()
          else
            empty = SlotManager.getLastEmptySlot()
          end
          if (empty == nil) then
            SlotManager.loadSlot(token)
            return false, "No space"
          end
          local ok, err = shiftItem(sortslot, empty, nil, true)
          if (ok) then
            inv[empty], inv[sortslot] = inv[sortslot], inv[empty]
            inv[empty].slot = empty
            inv[sortslot].slot = sortslot
          else
            SlotManager.loadSlot(token)
            return false, err
          end
        end
        local ok, err = shiftItem(itemslot, sortslot, nil, true)
        if (ok) then
          inv[sortslot], inv[itemslot] = inv[itemslot], inv[sortslot]
          inv[sortslot].slot = sortslot
          inv[itemslot].slot = itemslot
        else
          SlotManager.loadSlot(token)
          return false, err
        end
      end
    end
  end
  SlotManager.loadSlot(token)
  return true
end

function stackItem(reverse)
  for i = 1, 16 do
    local i2 = i
    if (not reverse) then i2 = 17 - i2 end
    for j = i + 1, 16 do
      local j2 = j
      if (not reverse) then j2 = 17 - j2 end
      if (not isLocked(i2, j2)) then
        if (turtle.getItemCount(i2) ~= 0 and turtle.getItemCount(j2) ~= 0) then
          shiftItem(i2, j2, nil, true)
        end
      end
    end
  end
end

function canShift(from, to, qty)
  local lock, err = isLocked(from, to)
  if (lock) then return false, err end
  local quantity = qty or 1
  -- No items
  if (turtle.getItemCount(from) == 0) then
    return false, "No Item"
  end
  -- Space shortage
  if (turtle.getItemSpace(to) < quantity) then
    return false, "No space"
  end
  -- Equal slots
  if (from == to) then
    return false, "Equal slots"
  end
  -- Empty slot
  if (turtle.getItemCount(to) == 0) then return true end
  -- Identical items
  if (SlotManager.isIdenticalItem(to, from, "exact")) then return true end
  -- Different items
  return false, "Different items"
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
