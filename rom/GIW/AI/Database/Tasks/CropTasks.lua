version = 1.00

function unloadCrops()
  return function(info)
    Inventory.stackItem()
    local dir = info.save.next
    local keep = {}
    local switch, slot = Inventory.switchFuel()
    if (slot ~= nil) then keep[slot] = true end
    for i, v in ipairs(info.config.Plant) do
      local seeddata = {name = v.seed, damage = v.sdamage}
      local slot = Inventory.getFirstItem(seeddata)
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

--------

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
