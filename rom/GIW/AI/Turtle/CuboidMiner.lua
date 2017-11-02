version = "1.42"

status = {}
status[1] = "base"
status[2] = "advance"
status[3] = "workDig"
status[4] = "workCondition"
status[5] = "workInventory"
status[6] = "workRoute"
status[7] = "workBack"
status[8] = "postWork"
status[9] = "retreat"

--conflict = "key"

-- init

Init = AIData:instance("init", "SINGLE", "MULTI")
Init:addRule(Rules.ParameterRules.firstTask())
Init:addTask(Tasks.UtilTasks.loadConfig("Miner_config"))
Init:addTask(Tasks.MapTasks.reloadCoord(0, 0, 1, "NORTH"))
Init:addTask(Tasks.RangeTasks.init3D())
Init:addTask(Tasks.ParameterTasks.setData("finish", false))
Init:addTask(Tasks.ParameterTasks.setTemporaryData("map"))
Init:addTask(Tasks.ParameterTasks.setTemporaryData("route"))
Init:addTask(Tasks.ParameterTasks.setTemporaryData("continuePoint"))
Init:addTask(Tasks.ParameterTasks.setTemporaryData("eventlog"))
Init:addTask(Tasks.UtilTasks.saveCoord())
Init:addTask(Tasks.UtilTasks.toConfigPos("Fuel"))
Init:addTask(Tasks.InventoryTasks.supplyFuel())
Init:addTask(Tasks.UtilTasks.moveBack())

-- base

EnterBase = AIData:instance("base", "SINGLE", "MULTI")
EnterBase:addRule(Rules.MapRules.coord(0, 0, 0))
EnterBase:addTask(Tasks.TurtleTasks.turn("SOUTH"))
EnterBase:addTask(Tasks.TurtleTasks.move("FORWARD"))

Finish = AIData:instance("base", "AND", "MULTI")
Finish:addRule(Rules.MapRules.coord(0, 0, 1))
Finish:addRule(Rules.ParameterRules.parameter("finish", "==", true))
Finish:addTask(Tasks.InventoryTasks.dispose())
Finish:addTask(Tasks.UtilTasks.saveCoord())
Finish:addTask(Tasks.UtilTasks.toConfigPos("Unload"))
Finish:addTask(Tasks.InventoryTasks.unload())
Finish:addTask(Tasks.UtilTasks.moveBack())
Finish:addTask(Tasks.TurtleTasks.turn("NORTH"))
Finish:addTask(Tasks.ParameterTasks.setState("exit"))

LeaveBase = AIData:instance("base", "SINGLE", "MULTI")
LeaveBase:addRule(Rules.MapRules.coord(0, 0, 1))
LeaveBase:addTask(Tasks.UtilTasks.saveCoord())
LeaveBase:addTask(Tasks.UtilTasks.toConfigPos("Unload"))
LeaveBase:addTask(Tasks.InventoryTasks.unload())
LeaveBase:addTask(Tasks.UtilTasks.toConfigPos("Fuel"))
LeaveBase:addTask(Tasks.InventoryTasks.supplyFuel())
LeaveBase:addTask(Tasks.UtilTasks.moveBack())
LeaveBase:addTask(Tasks.TurtleTasks.turn("NORTH"))
LeaveBase:addTask(Tasks.TurtleTasks.move("FORWARD"))
LeaveBase:addTask(Tasks.ParameterTasks.setState("advance"))

-- advance

Advance = AIData:instance("advance", "AND", "SINGLE")
Advance:addRule(Rules.ParameterRules.parameterI("nextY", "~=", "coord.y"))
Advance:addRule(Rules.RangeRules.obstruction(), false)
Advance:addTask(Tasks.RangeTasks.moveAdvance())

ToWork = AIData:instance("advance", "SINGLE", "MULTI")
ToWork:addRule(Rules.ParameterRules.parameterI("nextY", "==", "coord.y"))
ToWork:addTask(Tasks.ParameterTasks.setState("workDig"))

EndDepth = AIData:instance("advance", "SINGLE", "MULTI", 10)
EndDepth:addRule(Rules.RangeRules.obstruction())
EndDepth:addTask(Tasks.RangeTasks.lastPreWork())
EndDepth:addTask(Tasks.ParameterTasks.copyData("coord.y", "nextY"))
EndDepth:addTask(Tasks.ParameterTasks.setData("finish", true))

LimitDepth = AIData:instance("advance", "SINGLE", "MULTI", 20)
LimitDepth:addRule(Rules.RangeRules.limitDepth())
LimitDepth:addTask(Tasks.RangeTasks.lastPreWork())
LimitDepth:addTask(Tasks.ParameterTasks.copyData("coord.y", "nextY"))
LimitDepth:addTask(Tasks.ParameterTasks.setData("finish", true))
LimitDepth:addTask(Tasks.ParameterTasks.setState("workDig"))

-- workDig

DigUp = AIData:instance("workDig", "AND", "SINGLE")
DigUp:addRule(Rules.MapRules.getState("undefined", "UP"))
DigUp:addTask(Tasks.TurtleTasks.dig("UP"))

DigDown = AIData:instance("workDig", "AND", "SINGLE")
DigDown:addRule(Rules.MapRules.getState("undefined", "DOWN"))
DigDown:addTask(Tasks.TurtleTasks.dig("DOWN"))

workToCondition = AIData:instance("workDig", "AND", "SINGLE")
workToCondition:addRule(Rules.MapRules.getState("undefined", "UP"), false)
workToCondition:addRule(Rules.MapRules.getState("undefined", "DOWN"), false)
workToCondition:addTask(Tasks.ParameterTasks.setState("workCondition"))

--[[
RemoveUp = AIData:instance("work", "AND", "MULTI", 10)
RemoveUp:addRule(Rules.TurtleTasks.isLiquidSource("UP"))
RemoveUp:addTask(Tasks.TurtleTasks.move("UP"))
RemoveUp:addTask(Tasks.TurtleTasks.move("DOWN"))

RemoveDown = AIData:instance("work", "AND", "MULTI", 10)
RemoveDown:addRule(Rules.TurtleTasks.isLiquidSource("DOWN"))
RemoveDown:addTask(Tasks.TurtleTasks.move("DOWN"))
RemoveDown:addTask(Tasks.TurtleTasks.move("UP"))
--]]

-- workCondition

CheckCondition = AIData:instance("workCondition", "AND", "SINGLE", 100)
CheckCondition:addRule(Rules.FuelRules.checkAndConsume())
CheckCondition:addRule(Rules.InventoryRules.hasEmptySlot())
CheckCondition:addTask(Tasks.ParameterTasks.setState("workRoute"))

NeedFuel = AIData:instance("workCondition", "SINGLE", "MULTI", 50)
NeedFuel:addRule(Rules.FuelRules.checkAndConsume(), false)
NeedFuel:addTask(Tasks.ParameterTasks.setData("route", nil))
NeedFuel:addTask(Tasks.ParameterTasks.setData("finish", false))
NeedFuel:addTask(Tasks.ParameterTasks.setState("workBack"))

NeedSpace = AIData:instance("workCondition", "SINGLE", "MULTI")
NeedSpace:addRule(Rules.InventoryRules.hasEmptySlot(), false)
NeedSpace:addTask(Tasks.InventoryTasks.dispose())
NeedSpace:addTask(Tasks.ParameterTasks.setState("workInventory"))

-- workInventory

HasSpace = AIData:instance("workInventory", "SINGLE", "MULTI")
HasSpace:addRule(Rules.InventoryRules.hasEmptySlotCount(2))
HasSpace:addTask(Tasks.ParameterTasks.setState("workRoute"))

NoSpace = AIData:instance("workInventory", "SINGLE", "MULTI")
NoSpace:addRule(Rules.InventoryRules.hasEmptySlotCount(2), false)
NoSpace:addTask(Tasks.ParameterTasks.setData("route", nil))
NoSpace:addTask(Tasks.ParameterTasks.setData("finish", false))
NoSpace:addTask(Tasks.ParameterTasks.setState("workBack"))

-- workRoute

GetRoute = AIData:instance("workRoute", "SINGLE", "INTERRUPTER")
GetRoute:addRule(Rules.ParameterRules.parameter("route", "==", nil))
GetRoute:addTask(Tasks.Route_Accordion.setRoute("undefined"))
GetRoute:addTask(Tasks.Route_BreadthFirst.setRoute("blank", "undefined"))
GetRoute:addTask(Tasks.ParameterTasks.setData("LayerComplete", true))
GetRoute:addTask(Tasks.ParameterTasks.setState("workBack"))

TraceRoute = AIData:instance("workRoute", "SINGLE", "MULTI")
TraceRoute:addRule(Rules.ParameterRules.parameter("route", "~=", nil))
TraceRoute:addTask(Tasks.MapTasks.traceRoute())
TraceRoute:addTask(Tasks.ParameterTasks.setState("workDig"))

-- workBack

ToShaftPos = AIData:instance("workBack", "AND", "INTERRUPTER")
ToShaftPos:addRule(Rules.ParameterRules.parameter("route", "==", nil))
ToShaftPos:addTask(Tasks.Route_BreadthFirst.setRoute({"blank"}, {x = 0, z = 0}))
ToShaftPos:addTask(Tasks.Route_BreadthFirst.setRoute({"blank", "undefined"}, {x = 0, z = 0}))
ToShaftPos:addTask(Tasks.ParameterTasks.setState("postWork"))

MoveBack = AIData:instance("workBack", "SINGLE", "SINGLE")
MoveBack:addRule(Rules.ParameterRules.parameter("route", "~=", nil))
MoveBack:addTask(Tasks.MapTasks.traceRoute())

DigUp_Back = AIData:instance("workBack", "SINGLE", "SINGLE", 10)
DigUp_Back:addRule(Rules.MapRules.getState("undefined", "UP"))
DigUp_Back:addTask(Tasks.TurtleTasks.dig("UP"))

DigDown_Back = AIData:instance("workBack", "SINGLE", "SINGLE", 10)
DigDown_Back:addRule(Rules.MapRules.getState("undefined", "DOWN"))
DigDown_Back:addTask(Tasks.TurtleTasks.dig("DOWN"))

-- postWork

ToAdvance = AIData:instance("postWork", "AND", "MULTI")
ToAdvance:addRule(Rules.ParameterRules.parameter("LayerComplete", "==", true))
ToAdvance:addRule(Rules.ParameterRules.parameter("finish", "~=", true))
ToAdvance:addTask(Tasks.RangeTasks.updateDepth())
ToAdvance:addTask(Tasks.ParameterTasks.setData("LayerComplete", false))
ToAdvance:addTask(Tasks.ParameterTasks.setState("advance"))

ToRetreat = AIData:instance("postWork", "OR", "SINGLE")
ToRetreat:addRule(Rules.ParameterRules.parameter("LayerComplete", "~=", true))
ToRetreat:addRule(Rules.ParameterRules.parameter("finish", "==", true))
ToRetreat:addTask(Tasks.ParameterTasks.setState("retreat"))

-- retreat

Retreat = AIData:instance("retreat", "SINGLE", "SINGLE")
Retreat:addRule(Rules.MapRules.yCoord(0), false)
Retreat:addTask(Tasks.RangeTasks.moveRetreat())

ToBase = AIData:instance("retreat", "SINGLE", "SINGLE")
ToBase:addRule(Rules.MapRules.yCoord(0))
ToBase:addTask(Tasks.ParameterTasks.setState("base"))

--[[
Debug = AIData:instance("postWork", "SINGLE", "SINGLE", -math.huge)
Debug:addRule(Rules.Debug.printT("debug"))
Debug:addTask(Tasks.ParameterTasks.setState("exit"))
--]]
