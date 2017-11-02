version = "1.12"

status = {}
status[1] = "base"
status[2] = "move"
status[3] = "root"
status[4] = "plant"
status[5] = "lumber"
status[6] = "descent"
status[7] = "return"
status[8] = "next"

--conflict = "key"

-- init

Init = AIData:instance("init", "SINGLE", "MULTI", 100)
Init:addRule(Rules.ParameterRules.firstTask())
Init:addTask(Tasks.UtilTasks.loadConfig("Farmer_config"))
Init:addTask(Tasks.MapTasks.reloadCoord(0, 0, 1, "NORTH"))
Init:addTask(Tasks.RangeTasks.init2D())
Init:addTask(Tasks.UtilTasks.selectNumber("Waiting", "poszero", "stime"))
Init:addTask(Tasks.ParameterTasks.setData("nextX", 0))
Init:addTask(Tasks.ParameterTasks.setData("nextZ", 0))
Init:addTask(Tasks.UtilTasks.saveCoord())
Init:addTask(Tasks.UtilTasks.toConfigPos("Fuel"))
Init:addTask(Tasks.InventoryTasks.supplyFuel())
Init:addTask(Tasks.UtilTasks.moveBack())
Init:addTask(Tasks.TurtleTasks.move("UP"))
Init:addTask(Tasks.ParameterTasks.setTemporaryData("map"))
Init:addTask(Tasks.ParameterTasks.setTemporaryData("eventlog"))

RegMaterial = AIData:instance("init", "AND", "MULTI")
RegMaterial:addRule(Rules.InventoryRules.isEmptySlot(1), false)
RegMaterial:addRule(Rules.InventoryRules.isEmptySlot(2), false)
RegMaterial:addTask(Tasks.InventoryTasks.register("sapling", 1))
RegMaterial:addTask(Tasks.InventoryTasks.register("logblock", 2))
RegMaterial:addTask(Tasks.ParameterTasks.setState("base"))

RequestSapling = AIData:instance("init", "SINGLE", "MULTI")
RequestSapling:addRule(Rules.InventoryRules.isEmptySlot(1))
RequestSapling:addTask(Tasks.UtilTasks.message("MaterialError1"))
RequestSapling:addTask(Tasks.UtilTasks.message("MaterialError3"))
RequestSapling:addTask(Tasks.UtilTasks.waitForKey())

RequestLog = AIData:instance("init", "SINGLE", "MULTI")
RequestLog:addRule(Rules.InventoryRules.isEmptySlot(2))
RequestLog:addTask(Tasks.UtilTasks.message("MaterialError2"))
RequestLog:addTask(Tasks.UtilTasks.message("MaterialError3"))
RequestLog:addTask(Tasks.UtilTasks.waitForKey())

-- base

EnterBase = AIData:instance("base", "SINGLE", "MULTI")
EnterBase:addRule(Rules.MapRules.coord(0, 1, 0))
EnterBase:addTask(Tasks.TurtleTasks.turn("SOUTH"))
EnterBase:addTask(Tasks.TurtleTasks.move("FORWARD"))
EnterBase:addTask(Tasks.UtilTasks.saveCoord())
EnterBase:addTask(Tasks.UtilTasks.toConfigPos("Unload"))
EnterBase:addTask(Tasks.InventoryTasks.unload("sapling"))
EnterBase:addTask(Tasks.UtilTasks.toConfigPos("Fuel"))
EnterBase:addTask(Tasks.InventoryTasks.supplyFuel())
EnterBase:addTask(Tasks.UtilTasks.toConfigPos("Material"))
EnterBase:addTask(Tasks.InventoryTasks.supply("sapling", true))
EnterBase:addTask(Tasks.UtilTasks.moveBack())

Restart = AIData:instance("base", "AND", "MULTI", 100)
Restart:addRule(Rules.MapRules.coord(0, 1, 1))
Restart:addRule(Rules.ParameterRules.parameter("restart", "==", true))
Restart:addTask(Tasks.ParameterTasks.setData("restart", "==", false))
Restart:addTask(Tasks.ParameterTasks.setData("nextX", 0))
Restart:addTask(Tasks.ParameterTasks.setData("nextZ", 0))
Restart:addTask(Tasks.UtilTasks.sleepI("stime"))

LeaveBase = AIData:instance("base", "SINGLE", "MULTI")
LeaveBase:addRule(Rules.MapRules.coord(0, 1, 1))
LeaveBase:addTask(Tasks.UtilTasks.saveCoord())
LeaveBase:addTask(Tasks.TurtleTasks.turn("NORTH"))
LeaveBase:addTask(Tasks.TurtleTasks.move("FORWARD"))
LeaveBase:addTask(Tasks.ParameterTasks.setState("move"))

-- move

MoveNorth = AIData:instance("move", "SINGLE", "MULTI", 50)
MoveNorth:addRule(Rules.ParameterRules.parameterI("coord.z", ">" ,"nextZ"))
MoveNorth:addTask(Tasks.TurtleTasks.turn("NORTH"))
MoveNorth:addTask(Tasks.TurtleTasks.move("FORWARD"))
MoveNorth:addTask(Tasks.TurtleTasks.suck("DOWN"))

MoveSouth = AIData:instance("move", "SINGLE", "MULTI", 50)
MoveSouth:addRule(Rules.ParameterRules.parameterI("coord.z", "<" ,"nextZ"))
MoveSouth:addTask(Tasks.TurtleTasks.turn("SOUTH"))
MoveSouth:addTask(Tasks.TurtleTasks.move("FORWARD"))
MoveSouth:addTask(Tasks.TurtleTasks.suck("DOWN"))

MoveEast = AIData:instance("move", "SINGLE", "MULTI")
MoveEast:addRule(Rules.ParameterRules.parameterI("coord.x", "<" ,"nextX"))
MoveEast:addTask(Tasks.TurtleTasks.turn("EAST"))
MoveEast:addTask(Tasks.TurtleTasks.move("FORWARD"))
MoveEast:addTask(Tasks.TurtleTasks.suck("DOWN"))

MoveToReturn = AIData:instance("move", "SINGLE", "SINGLE", 100)
MoveToReturn:addRule(Rules.FuelRules.checkAndConsume(), false)
MoveToReturn:addTask(Tasks.ParameterTasks.setState("return"))

-- root

Root = AIData:instance("plant", "SINGLE", "MULTI")
Root:addRule(Rules.TurtleRules.inspectCompare("DOWN", "logblock"))
Root:addTask(Tasks.TurtleTasks.dig("DOWN"))

-- plant

Plant = AIData:instance("plant", "AND", "MULTI")
Plant:addRule(Rules.TurtleRules.detect("DOWN"), false)
Plant:addRule(Rules.InventoryRules.hasItemI("sapling"))
Plant:addTask(Tasks.InventoryTasks.selectByIndex("sapling"))
Plant:addTask(Tasks.TurtleTasks.place("DOWN"))
Plant:addTask(Tasks.ParameterTasks.setState("lumber"))

-- lumber

lumber = AIData:instance("lumber", "AND", "MULTI")
lumber:addRule(Rules.TurtleRules.inspectCompare("UP", "logblock"))
lumber:addTask(Tasks.TurtleTasks.move("UP"))

-- descent

Descent = AIData:instance("descent", "SINGLE", "SINGLE", 100)
Descent:addRule(Rules.MapRules.yCoord(1), false)
Descent:addTask(Tasks.TurtleTasks.move("DOWN"))

DescentToNext = AIData:instance("descent", "AND", "SINGLE")
DescentToNext:addRule(Rules.FuelRules.checkAndConsume())
DescentToNext:addRule(Rules.InventoryRules.hasEmptySlot())
DescentToNext:addTask(Tasks.ParameterTasks.setState("next"))

DescentToReturn = AIData:instance("descent", "OR", "SINGLE")
DescentToReturn:addRule(Rules.FuelRules.checkAndConsume(), false)
DescentToReturn:addRule(Rules.InventoryRules.hasEmptySlot(), false)
DescentToReturn:addTask(Tasks.ParameterTasks.setState("return"))

-- return

ReturnWest = AIData:instance("return", "SINGLE", "MULTI", 75)
ReturnWest:addRule(Rules.ParameterRules.parameterI("coord.x", ">", "range.minWidth"))
ReturnWest:addTask(Tasks.TurtleTasks.turn("WEST"))
ReturnWest:addTask(Tasks.TurtleTasks.move("FORWARD"))

ReturnSouth = AIData:instance("return", "SINGLE", "MULTI", 50)
ReturnSouth:addRule(Rules.ParameterRules.parameterI("coord.z", "<", "range.maxDepth"))
ReturnSouth:addTask(Tasks.TurtleTasks.turn("SOUTH"))
ReturnSouth:addTask(Tasks.TurtleTasks.move("FORWARD"))

ReturnToHome = AIData:instance("return", "SINGLE", "SINGLE")
ReturnToHome:addRule(Rules.MapRules.coord(0, 1, 0))
ReturnToHome:addTask(Tasks.ParameterTasks.setState("base"))

-- next

NextNorth = AIData:instance("next", "AND", "MULTI", 50)
NextNorth:addRule(Rules.ParameterRules.isEven("nextX"))
NextNorth:addRule(Rules.ParameterRules.parameterI("nextZ", ">", "range.minDepth"))
NextNorth:addTask(Tasks.ParameterTasks.subData("nextZ", 1))
NextNorth:addTask(Tasks.ParameterTasks.setState("move"))

NextSouth = AIData:instance("next", "AND", "MULTI", 50)
NextSouth:addRule(Rules.ParameterRules.isOdd("nextX"))
NextSouth:addRule(Rules.ParameterRules.parameterI("nextZ", "<", "range.maxDepth"))
NextSouth:addTask(Tasks.ParameterTasks.addData("nextZ", 1))
NextSouth:addTask(Tasks.ParameterTasks.setState("move"))

NextEast = AIData:instance("next", "OR", "MULTI")
NextEast:addRule(Rules.ParameterRules.parameterI("nextZ", "==", "range.minDepth"))
NextEast:addRule(Rules.ParameterRules.parameterI("nextZ", "==", "range.maxDepth"))
NextEast:addTask(Tasks.ParameterTasks.addData("nextX", 1))
NextEast:addTask(Tasks.ParameterTasks.setState("move"))

WorkEnd1 = AIData:instance("next", "AND", "MULTI", 100)
WorkEnd1:addRule(Rules.ParameterRules.isEven("range.maxWidth"))
WorkEnd1:addRule(Rules.ParameterRules.parameterI("nextX", "==", "range.maxWidth"))
WorkEnd1:addRule(Rules.ParameterRules.parameterI("nextZ", "==", "range.minDepth"))
WorkEnd1:addTask(Tasks.ParameterTasks.setData("restart", true))
WorkEnd1:addTask(Tasks.ParameterTasks.setState("return"))

WorkEnd2 = AIData:instance("next", "AND", "MULTI", 100)
WorkEnd2:addRule(Rules.ParameterRules.isOdd("range.maxWidth"))
WorkEnd2:addRule(Rules.ParameterRules.parameterI("nextX", "==", "range.maxWidth"))
WorkEnd2:addRule(Rules.ParameterRules.parameterI("nextZ", "==", "range.maxDepth"))
WorkEnd2:addTask(Tasks.ParameterTasks.setData("restart", true))
WorkEnd2:addTask(Tasks.ParameterTasks.setState("return"))
