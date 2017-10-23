version = "1.10"

status = {}
status[1] = "base"
status[2] = "advance"
status[3] = "work"
status[4] = "postWork"
status[5] = "retreat"

conflict = key

-- init

initVariable = AIData:instance("init", "SINGLE", "MULTI")
initVariable:addRule(Rules.Variable.firstTask)
initVariable:addTask(Tasks.Variable.setRange3D)
initVariable:addTask(Tasks.MapState.reloadCoord(0, 0, 1, "NORTH"))
initVariable:addTask(Tasks.Variable.setData("nextY", 1))
initVariable:addTask(Tasks.Inventory.supply("Miner_config"))
initVariable:addTask(Tasks.Variable.setTemporaryData("map"))
initVariable:addTask(Tasks.Variable.setTemporaryData("route"))
initVariable:addTask(Tasks.Variable.setTemporaryData("continuePoint"))

-- base

enterBase = AIData:instance("base", "SINGLE", "MULTI")
enterBase:addRule(Rules.MapState.coord(0, 0, 0))
enterBase:addTask(Tasks.TurtleTasks.turn("SOUTH"))
enterBase:addTask(Tasks.TurtleTasks.move("FORWARD"))
enterBase:addTask(Tasks.Inventory.unload("Miner_config"))
enterBase:addTask(Tasks.Inventory.supply("Miner_config"))

finish = AIData:instance("base", "AND", "MULTI")
finish:addRule(Rules.MapState.coord(0, 0, 1))
finish:addRule(Rules.Variable.compareIndexValue("finish", "==", true))
finish:addTask(Tasks.TurtleTasks.turn("NORTH"))
finish:addTask(Tasks.Variable.setState("exit"))

leaveBase = AIData:instance("base", "SINGLE", "MULTI")
leaveBase:addRule(Rules.MapState.coord(0, 0, 1))
leaveBase:addRule(Rules.FuelState.checkAndConsume)
leaveBase:addTask(Tasks.TurtleTasks.turn("NORTH"))
leaveBase:addTask(Tasks.TurtleTasks.move("FORWARD"))
leaveBase:addTask(Tasks.Variable.setState("advance"))

-- advance

advance1 = AIData:instance("advance", "AND", "SINGLE")
advance1:addRule(Rules.Variable.compareIndexIndex("nextY", "~=", "coord.y"))
advance1:addRule(Rules.MapState.getState("obstruction", "UP"), false)
advance1:addTask(Tasks.TurtleTasks.move("UP"))

advance2 = AIData:instance("advance", "SINGLE", "MULTI", 100)
advance2:addRule(Rules.Variable.compareIndexIndex("nextY", "==", "coord.y"))
advance2:addTask(Tasks.Variable.setState("work"))

advance3 = AIData:instance("advance", "SINGLE", "MULTI", 50)
advance3:addRule(Rules.MapState.getState("obstruction", "UP"))
advance3:addTask(Tasks.Variable.copyData("coord.y", "nextY"))
advance3:addTask(Tasks.Variable.setData("finish", true))
advance3:addTask(Tasks.Variable.setState("work"))

advance4 = AIData:instance("advance", "SINGLE", "MULTI", 150)
advance4:addRule(Rules.Variable.compareIndexIndex("range.maxHeight", "==", "coord.y"))
advance4:addTask(Tasks.Variable.copyData("coord.y", "nextY"))
advance4:addTask(Tasks.Variable.setData("finish", true))
advance4:addTask(Tasks.Variable.setState("work"))

-- work

workDigUp = AIData:instance("work", "AND", "SINGLE", 150)
workDigUp:addRule(Rules.MapState.getState("undefined", "UP"))
workDigUp:addRule(Rules.InventoryState.hasEmptySlot)
workDigUp:addTask(Tasks.TurtleTasks.dig("UP"))

workDigDown = AIData:instance("work", "AND", "SINGLE", 150)
workDigDown:addRule(Rules.MapState.getState("undefined", "DOWN"))
workDigDown:addRule(Rules.InventoryState.hasEmptySlot)
workDigDown:addTask(Tasks.TurtleTasks.dig("DOWN"))

workRemoveUp = AIData:instance("work", "AND", "MULTI", 100)
workRemoveUp:addRule(Rules.TurtleTasks.isLiquidSource("UP"))
workRemoveUp:addTask(Tasks.TurtleTasks.move("UP"))
workRemoveUp:addTask(Tasks.TurtleTasks.move("DOWN"))

workRemoveDown = AIData:instance("work", "AND", "MULTI", 100)
workRemoveDown:addRule(Rules.TurtleTasks.isLiquidSource("DOWN"))
workRemoveDown:addTask(Tasks.TurtleTasks.move("DOWN"))
workRemoveDown:addTask(Tasks.TurtleTasks.move("UP"))

workRoute = AIData:instance("work", "SINGLE", "INTERRUPTER", 50)
workRoute:addRule(Rules.Variable.compareIndexValue("route", "==", nil))
workRoute:addTask(Tasks.Variable.setData("interrupt", false))
workRoute:addTask(Tasks.Route_Accordion.setRoute("undefined"))
workRoute:addTask(Tasks.Route_BreadthFirst.setRoute("blank", "undefined"))
workRoute:addTask(Tasks.Route_BreadthFirst.setRoute({"blank", "undefined"}, {x = 0, z = 0}))
workRoute:addTask(Tasks.Variable.setState("postWork"))

workMove = AIData:instance("work", "AND", "SINGLE")
workMove:addRule(Rules.Variable.compareIndexValue("route", "~=", nil))
workMove:addTask(Tasks.MapState.traceRoute)

workDispose = AIData:instance("work", "AND", "SINGLE", 150)
workDispose:addRule(Rules.InventoryState.hasEmptySlotCount(2), false)
workDispose:addRule(Rules.Variable.chain("workDispose"), false)
workDispose:addRule(Rules.Variable.compareIndexValue("interrupt", "~=", true))
workDispose:addTask(Tasks.Inventory.dispose("Miner_config"))

workInterruption = AIData:instance("work", "WEIGHT", "MULTI", 125)
workInterruption:addRule(Rules.FuelState.checkAndConsume, 1, false)
workInterruption:addRule(Rules.InventoryState.hasEmptySlotCount(2), 1, false)
workInterruption:addRule(Rules.Variable.compareIndexValue("interrupt", "==", true), -2)
workInterruption:addTask(Tasks.Variable.setData("route", nil))
workInterruption:addTask(Tasks.Variable.setData("interrupt", true))
workInterruption:addTask(Tasks.Variable.setData("finish", nil))
workInterruption:addTask(Tasks.Route_BreadthFirst.setRoute({"blank", "undefined"}, {x = 0, z = 0}))

workToPostWork = AIData:instance("work", "AND", "MULTI")
workToPostWork:addRule(Rules.MapState.compare("x", "==", 0))
workToPostWork:addRule(Rules.MapState.compare("z", "==", 0))
workToPostWork:addRule(Rules.Variable.compareIndexValue("interrupt", "==", true))
workToPostWork:addTask(Tasks.Variable.setState("postWork"))

-- postWork

postWorkToAdvance = AIData:instance("postWork", "AND", "MULTI", 150)
postWorkToAdvance:addRule(Rules.FuelState.checkAndConsume)
postWorkToAdvance:addRule(Rules.InventoryState.hasEmptySlotCount(2))
postWorkToAdvance:addRule(Rules.Variable.compareIndexValue("interrupt", "==", false))
postWorkToAdvance:addTask(Tasks.Variable.setState("advance"))
postWorkToAdvance:addTask(Tasks.Variable.addData("nextY", 3))

postWorkToWork = AIData:instance("postWork", "AND", "MULTI", 250)
postWorkToWork:addRule(Rules.FuelState.checkAndConsume)
postWorkToWork:addRule(Rules.InventoryState.hasEmptySlotCount(2))
postWorkToWork:addRule(Rules.Variable.compareIndexValue("interrupt", "==", true))
postWorkToWork:addTask(Tasks.Variable.setState("work"))

postWorkToRetreat = AIData:instance("postWork", "OR", "SINGLE")
postWorkToRetreat:addRule(Rules.FuelState.checkAndConsume, false)
postWorkToRetreat:addRule(Rules.InventoryState.hasEmptySlotCount(2), false)
postWorkToRetreat:addTask(Tasks.Variable.setState("retreat"))

postWorkToFinish = AIData:instance("postWork", "AND", "SINGLE", 200)
postWorkToFinish:addRule(Rules.Variable.compareIndexValue("finish", "==", true))
postWorkToFinish:addTask(Tasks.Variable.setState("retreat"))

-- retreat

retreat1 = AIData:instance("retreat", "SINGLE", "SINGLE")
retreat1:addRule(Rules.MapState.compare("y", "~=", 0))
retreat1:addTask(Tasks.TurtleTasks.move("DOWN"))

retreat2 = AIData:instance("retreat", "SINGLE", "SINGLE")
retreat2:addRule(Rules.MapState.compare("y", "==", 0))
retreat2:addTask(Tasks.Variable.setState("base"))

--[[
Debug = AIData:instance("postWork", "SINGLE", "SINGLE", -math.huge)
Debug:addRule(Rules.Debug.printT("debug"))
Debug:addTask(Tasks.Variable.setState("exit"))
--]]
