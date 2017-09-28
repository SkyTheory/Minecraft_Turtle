version = "1.00"

dependency.require("ItemManager", "SlotManager", "FuelManager")
dependency.after("ItemManager", "SlotManager", "FuelManager")
dependency.before()

setmetatable(class, {__index = GIWCore.indexHandler(ItemManager, SlotManager, FuelManager)})
