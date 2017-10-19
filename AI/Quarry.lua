version = "1.00"

status = {}
status[1] = "base"
status[2] = "descent"
status[3] = "work"
status[4] = "postWork"
status[5] = "ascent"

conflict = key

-- init

initQuarry = AIData:instance("init", "SINGLE", "MULTI")
initQuarry:addRule(Rules.Variable.firstTask)
initQuarry:addTask(Tasks.Variable.setRange2D)
initQuarry:addTask(Tasks.MapState.reloadCoord(0, 0, 1, "NORTH"))
initQuarry:addTask(Tasks.Variable.setData("nextY", -2))
initQuarry:addTask(Tasks.Inventory.supply("Quarry_config"))
initQuarry:addTask(Tasks.Variable.setTemporaryData("map"))
initQuarry:addTask(Tasks.Variable.setTemporaryData("route"))
initQuarry:addTask(Tasks.Variable.setTemporaryData("continuePoint"))

-- base

enterBase = AIData:instance("base", "SINGLE", "MULTI")
enterBase:addRule(Rules.MapState.coord(0, 0, 0))
enterBase:addTask(Tasks.TurtleTasks.turn("SOUTH"))
enterBase:addTask(Tasks.TurtleTasks.move("FORWARD"))
enterBase:addTask(Tasks.Inventory.unload("Quarry_config"))
enterBase:addTask(Tasks.Inventory.supply("Quarry_config"))

finish = AIData:instance("base", "AND", "MULTI")
finish:addRule(Rules.MapState.coord(0, 0, 1))
finish:addRule(Rules.Variable.data("finish", true))
finish:addTask(Tasks.TurtleTasks.turn("NORTH"))
finish:addTask(Tasks.Variable.setState("exit"))

leaveBase = AIData:instance("base", "SINGLE", "MULTI")
leaveBase:addRule(Rules.MapState.coord(0, 0, 1))
leaveBase:addRule(Rules.FuelState.checkAndConsume)
leaveBase:addTask(Tasks.TurtleTasks.turn("NORTH"))
leaveBase:addTask(Tasks.TurtleTasks.move("FORWARD"))
leaveBase:addTask(Tasks.Variable.setState("descent"))

-- descent

descent1 = AIData:instance("descent", "AND", "SINGLE")
descent1:addRule(Rules.Variable.referInfo("nextY", "coord.y"), false)
descent1:addRule(Rules.MapState.getState("obstruction", "DOWN"), false)
descent1:addTask(Tasks.TurtleTasks.move("DOWN"))

descent2 = AIData:instance("descent", "SINGLE", "MULTI", 100)
descent2:addRule(Rules.Variable.referInfo("nextY", "coord.y"))
descent2:addTask(Tasks.Variable.setState("work"))

descent3 = AIData:instance("descent", "SINGLE", "MULTI", 50)
descent3:addRule(Rules.MapState.getState("obstruction", "DOWN"))
descent3:addTask(Tasks.Variable.copyData("coord.y", "nextY"))
descent3:addTask(Tasks.Variable.setData("finish", true))
descent3:addTask(Tasks.Variable.setState("work"))

-- work

workDigUp = AIData:instance("work", "AND", "SINGLE", 100)
workDigUp:addRule(Rules.MapState.getState("undefined", "UP"))
workDigUp:addRule(Rules.InventoryState.hasEmptySlot)
workDigUp:addTask(Tasks.TurtleTasks.dig("UP"))

workDigDown = AIData:instance("work", "AND", "SINGLE", 100)
workDigDown:addRule(Rules.MapState.getState("undefined", "DOWN"))
workDigDown:addRule(Rules.InventoryState.hasEmptySlot)
workDigDown:addTask(Tasks.TurtleTasks.dig("DOWN"))

workRoute = AIData:instance("work", "SINGLE", "INTERRUPTER")
workRoute:addRule(Rules.Variable.data("route", nil))
workRoute:addTask(Tasks.Route_Accordion.setRoute("undefined"))
workRoute:addTask(Tasks.Route_BreadthFirst.setRoute("undefined"))
workRoute:addTask(Tasks.Variable.setState("postWork"))

workContinue = AIData:instance("work", "AND", "SINGLE")
workContinue:addRule(Rules.Variable.data("continuePoint", nil), false)
workContinue:addRule(Rules.Variable.data("route", nil))
workContinue:addTask(Tasks.Route_BreadthFirst.setRoute("index", "continuePoint"))
workContinue:addTask(Tasks.Variable.setData("continuePoint", nil))

workMove = AIData:instance("work", "AND", "SINGLE")
workMove:addRule(Rules.FuelState.checkAndConsume)
workMove:addRule(Rules.InventoryState.hasEmptySlot)
workMove:addRule(Rules.Variable.data("route", nil), false)
workMove:addTask(Tasks.MapState.traceRoute)

workDispose = AIData:instance("work", "AND", "SINGLE", 50)
workDispose:addRule(Rules.InventoryState.hasEmptySlot, false)
workDispose:addRule(Rules.Variable.chain(workDispose), false)
workDispose:addTask(Tasks.Inventory.dispose("Quarry_config"))

workInterruption = AIData:instance("work", "OR", "MULTI")
workInterruption:addRule(Rules.FuelState.checkAndConsume, false)
workInterruption:addRule(Rules.InventoryState.hasEmptySlot, false)
workInterruption:addTask(Tasks.Variable.copyData("coord.fields", "continuePoint"))
workInterruption:addTask(Tasks.Variable.setData("route", nil))
workInterruption:addTask(Tasks.Variable.setData("finish", nil))
workInterruption:addTask(Tasks.Variable.setState("postWork"))

-- postWork

postWorkRoute = AIData:instance("postWork", "WEIGHT", "MULTI", 50)
postWorkRoute:addRule(Rules.MapState.compare("x", "~=", 0), 1)
postWorkRoute:addRule(Rules.MapState.compare("z", "~=", 0), 1)
postWorkRoute:addRule(Rules.Variable.data("route", nil), -2, false)
postWorkRoute:addTask(Tasks.Route_BreadthFirst.setRoute({x = 0, z = 0}))

postWorkMove = AIData:instance("postWork", "SINGLE", "SINGLE")
postWorkMove:addRule(Rules.Variable.data("route", nil), false)
postWorkMove:addTask(Tasks.MapState.traceRoute)

postWorkDispose = AIData:instance("postWork", "AND", "SINGLE", 150)
postWorkDispose:addRule(Rules.MapState.compare("x", "==", 0))
postWorkDispose:addRule(Rules.MapState.compare("z", "==", 0))
postWorkDispose:addRule(Rules.Variable.chain(postWorkDispose), false)
postWorkDispose:addTask(Tasks.Inventory.dispose("Quarry_config"))

postWorkToDescent = AIData:instance("postWork", "AND", "MULTI", 100)
postWorkToDescent:addRule(Rules.MapState.compare("x", "==", 0))
postWorkToDescent:addRule(Rules.MapState.compare("z", "==", 0))
postWorkToDescent:addRule(Rules.FuelState.checkAndConsume)
postWorkToDescent:addRule(Rules.InventoryState.hasEmptySlot)
postWorkToDescent:addTask(Tasks.Variable.setState("descent"))
postWorkToDescent:addTask(Tasks.Variable.addData("nextY", -3))

postWorkToAscent = AIData:instance("postWork", "AND", "SINGLE")
postWorkToAscent:addRule(Rules.MapState.compare("x", "==", 0))
postWorkToAscent:addRule(Rules.MapState.compare("z", "==", 0))
postWorkToAscent:addTask(Tasks.Variable.setState("ascent"))

postWorkToFinish = AIData:instance("postWork", "AND", "SINGLE", 150)
postWorkToFinish:addRule(Rules.MapState.compare("x", "==", 0))
postWorkToFinish:addRule(Rules.MapState.compare("z", "==", 0))
postWorkToFinish:addRule(Rules.Variable.data("finish", true))
postWorkToFinish:addTask(Tasks.Variable.setState("ascent"))

-- ascent

ascent1 = AIData:instance("ascent", "SINGLE", "SINGLE")
ascent1:addRule(Rules.MapState.compare("y", "~=", 0))
ascent1:addTask(Tasks.TurtleTasks.move("UP"))

ascent2 = AIData:instance("ascent", "SINGLE", "SINGLE")
ascent2:addRule(Rules.MapState.compare("y", "==", 0))
ascent2:addTask(Tasks.Variable.setState("base"))

--[[
Debug = AIData:instance("postWork", "SINGLE", "SINGLE", -math.huge)
Debug:addRule(Rules.Debug.printT("debug"))
Debug:addTask(Tasks.Variable.setState("exit"))
--]]
