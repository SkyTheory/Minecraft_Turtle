version = "1.11"

dependency.require("SlotManager")
dependency.after("SlotManager")
dependency.before()

function condenseItem(mode)
  local reverse = false
  if (mode == false) then reverse = true end
  local token = SlotManager.saveSlot()
  for i = 1, 16 do
    for j = 1, i - 1 do
      local i2, j2 = i, j
      if (reverse) then
        i2 = 17 - i2
      end
      shiftItem(j2, i2, nil, true)
    end
  end
  SlotManager.loadSlot(token)
end

function transferFrom(from)
  local token = SlotManager.saveSlot()
  local slot = turtle.getSelectedSlot()
  turtle.select(from)
  local ok, err = turtle.transferTo(slot)
  SlotManager.loadSlot(token)
  return ok, err
end

function shiftItem(to, from, qty, disregard)
  local fromSlot = from or turtle.getSelectedSlot()
  local itemCount = turtle.getItemCount(fromSlot)
  local key
  local token
  if (not canShift(to, from, qty)) then return false end
  if (not disregard) then
    token = SlotManager.saveSlot()
  end
  if (turtle.getSelectedSlot() ~= fromSlot) then
    turtle.select(fromSlot)
  end
  if (qty) then
    turtle.transferTo(to, qty)
  else
    turtle.transferTo(to)
  end
  if (not disregard) then
    SlotManager.loadSlot(token)
  end
  return turtle.getItemCount(from) ~= itemCount
end

function sortItem(mode)
  local token = SlotManager.saveSlot()
  local items = {}
  local inv = {}
    local reverse = false
    if (mode == false) then reverse = true end
  -- Sort preparing
  stackItem(mode)
  if (not SlotManager.getFirstEmptySlot()) then
    SlotManager.loadSlot(token)
    return false
  end
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
      table.insert(inv, {slot = i, name = "EmptySlot", damage = 0})
    end
  end
  -- Table sort
  table.sort(items, compare(mode))
  for i = 1, #items do
    -- sortslot => current putting
    -- itemslot => target item in
    local sortslot = i
    local itemslot = items[sortslot].slot
    if (reverse) then sortslot = 17 - sortslot end
    if (sortslot ~= itemslot) then
      if (not SlotManager.isEmptySlot(sortslot)) then
        local empty
        if (not reverse) then
          empty = SlotManager.getLastEmptySlot()
        else
          empty = SlotManager.getFirstEmptySlot()
        end
        if (empty == 0) then
          print(sortslot)
          SlotManager.loadSlot(token)
          return false
        end
        if (shiftItem(empty, sortslot, nil, true)) then
          inv[empty], inv[sortslot] = inv[sortslot], inv[empty]
          inv[empty].slot = empty
          inv[sortslot].slot = sortslot
        else
          SlotManager.loadSlot(token)
          return false
        end
      end
      if (shiftItem(sortslot, itemslot, nil, true)) then
        inv[sortslot], inv[itemslot] = inv[itemslot], inv[sortslot]
        inv[sortslot].slot = sortslot
        inv[itemslot].slot = itemslot
      else
        SlotManager.loadSlot(token)
        return false
      end
    end
  end
  SlotManager.loadSlot(token)
  return true
end

function stackItem(mode)
  local reverse = false
  if (mode == false) then reverse = true end
  for i = 1, 16 do
    local i2 = i
    if (not reverse) then i2 = 17 - i2 end
    for j = i + 1, 16 do
      local j2 = j
      if (not reverse) then j2 = 17 - j2 end
      if (turtle.getItemDetail(i2) and turtle.getItemDetail(j2)) then
        shiftItem(j2, i2, nil, true)
      end
    end
  end
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
  if (SlotManager.isIdenticalItem(to, from, "exact")) then return true end
  -- Differemt items
  return false
end

function compare(mode)
  local reverse = false
  if (mode == false) then reverse = true end
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
