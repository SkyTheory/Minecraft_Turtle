version = "1.00"

dependency.require("ItemManager", "SlotManager", "FuelManager")
dependency.after("ItemManager", "SlotManager", "FuelManager")
dependency.before()

setmetatable(Inventory, {__index = GIWCore.indexHandler(ItemManager, SlotManager, FuelManager)})
