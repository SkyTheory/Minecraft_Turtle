version = 1.13

function select(slot)
  return function(info)
    Inventory.select(slot)
  end
end

function selectEmpty()
  return function(info)
    local slot = Inventory.getFirstEmptySlot()
    Inventory.select(slot)
  end
end

function selectByName(name, mode)
  return function(info)
    local slot = Inventory.getFirstItem(name, mode)
    Inventory.select(slot)
  end
end

function selectByIndex(index, mode)
  return function(info)
    local name = GIWUtil.getByIndex(info.fields, index)
    local slot = Inventory.getFirstItem(name, mode)
    Inventory.select(slot)
  end
end

function register(key, slot)
  return function(info)
    info[key] = Inventory.getItemName(slot)
  end
end

function condense(flag)
  return function(info)
    Inventory.condenseItem(flag)
  end
end

function sort(flag)
  return function(indo)
    Inventory.sortItem(flag)
  end
end

function unload(...)
  local keepIndex = {...}
  return function(info)
    Inventory.stackItem(true)
    local dir = info.save.next
    local keep = {}
    local switch, slot = Inventory.switchFuel()
    if (slot ~= nil) then keep[slot] = true end
    for i, index in ipairs(keepIndex) do
      local name = GIWUtil.getByIndex(info.fields, index)
      local slot = Inventory.getLastItem(name)
      if (slot ~= nil) then keep[slot] = true end
    end
    for i = 1, 16 do
      if (not keep[i]) then
        if (turtle.getItemCount(i) ~= 0) then
          Inventory.select(i)
          repeat
            local condition = (TurtleEx.detect(dir) and TurtleEx.drop(dir))
          until(validate(info, condition, "Unable to unload item"))
        end
      end
    end
    Inventory.select(1)
  end
end

function supplyFuel()
  return function(info)
    Inventory.stackItem(true)
    local dir = info.save.next
    repeat
      selectFuelSlot(info)
      Inventory.suckFull(dir)
      local condition = Inventory.chargeFuel(Inventory.getFuelCount(info.range) * 2)
    until(validate(info, condition, "Unable to supply fuel"))
    Inventory.suckFull(dir)
    Inventory.select(1)
  end
end

function supply(index, singlestack)
  return function(info)
    Inventory.stackItem(true)
    local dir = info.save.next
    local name = GIWUtil.getByIndex(info.fields, index)
    repeat
      if (singlestack) then
        local slot = Inventory.getLastItem(name)
        if (slot == nil) then
          Inventory.select(Inventory.getFirstEmptySlot())
        else
          Inventory.select(slot)
        end
        Inventory.suckFull(dir)
      else
        repeat
          local flag = TurtleEx.suck(dir)
        until(not flag)
      end
      local condition = (Inventory.getItemCountAll(name) ~= 0)
    until(validate(info, condition, "Unable to supply material"))
  end
end

function dispose()
  return function(info)
    Inventory.stackItem(true)
    local dir
    local taflag
    if (not TurtleEx.detect("FORWARD")) then dir = "FORWARD" end
    if (not TurtleEx.detect("UP")) then dir = "UP" end
    if (not TurtleEx.detect("DOWN")) then dir = "DOWN" end
    if (not dir) then
      TurtleEx.turn("BACK")
      if (not TurtleEx.detect("FORWARD")) then dir = "FORWARD" end
      taflag = true
    end
    if (dir) then
      for i, data in ipairs(info.config.Disposable) do
        local dslot
        repeat
          dslot = Inventory.getFirstItem(data, "auto")
          if (Inventory.select(dslot)) then
            TurtleEx.drop(dir)
          end
        until(not dslot)
      end
    end
    if (taflag) then
      TurtleEx.turn("BACK")
    end
  end
end

--------

function selectFuelSlot(info)
  local sf, slot = Inventory.switchFuel()
  if (sf) then
    Inventory.select(slot)
  else
    local flag
    repeat
      slot = Inventory.getLastEmptySlot()
      local condition = (slot ~= nil)
      flag = validate(info, condition, "Unable to supply fuel")
    until(flag)
    Inventory.select(slot)
  end
end

function validate(info, flag, msg)
  if (not flag) then
    if (info.config.Wait and info.config.Wait[1] == false) then
      return true
    else
      print(msg)
      print("Press any key to continue")
      os.pullEvent("key")
    end
  end
  return flag
end
