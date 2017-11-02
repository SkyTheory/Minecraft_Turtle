version = 1.00

function isHarvestable(dir, hasSeed, selectSeed)
  return function(info)
    local flag, data = TurtleEx.inspect(dir)
    if (not flag) then return false end
    for i, v in ipairs(info.config.Plant) do
      local cropdata = {name = v.name, metadata = v.harvest}
      if (GIWUtil.isIdentical(cropdata, data, "auto")) then
        if (hasSeed) then
          if (v.seed == nil) then return true end
          local seeddata = {name = v.seed, damage = v.sdamage}
          local seedslot = Inventory.getLastItem(seeddata)
          if (seedslot) then
            if (selectSeed) then
              Inventory.select(seedslot)
            end
            return true
          end
        else
          return true
        end
      end
    end
    for i, v in ipairs(info.config.Block) do
      local cropdata = {name = v.name, metadata = v.harvest}
      if (GIWUtil.isIdentical(cropdata, data, "auto")) then
        return true
      end
    end
    return false
  end
end
