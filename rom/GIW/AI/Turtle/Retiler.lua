version = "1.04"

status = {}
status[1] = "base"
status[2] = "move"
status[3] = "select"
status[4] = "retile"
status[5] = "return"
status[6] = "next"

--conflict = "key"

-- init

Init = AIData:instance("init", "SINGLE", "MULTI", 100)
Init:addRule(Rules.ParameterRules.firstTask())
Init:addTask(Tasks.UtilTasks.loadConfig("Retiler_config"))
Init:addTask(Tasks.MapTasks.reloadCoord(0, 0, 1, "NORTH"))
Init:addTask(Tasks.RangeTasks.init2D())
Init:addTask(Tasks.ParameterTasks.setData("nextX", 0))
Init:addTask(Tasks.ParameterTasks.setData("nextZ", 0))
Init:addTask(Tasks.ParameterTasks.setTemporaryData("route"))
Init:addTask(Tasks.UtilTasks.saveCoord())
Init:addTask(Tasks.UtilTasks.toConfigPos("Fuel"))
Init:addTask(Tasks.InventoryTasks.supplyFuel())
Init:addTask(Tasks.UtilTasks.moveBack())

RegMaterial = AIData:instance("init", "SINGLE", "MULTI")
RegMaterial:addRule(Rules.InventoryRules.isEmptySlot(1), false)
RegMaterial:addTask(Tasks.InventoryTasks.register("material", 1))
RegMaterial:addTask(Tasks.ParameterTasks.setState("base"))

Request = AIData:instance("init", "SINGLE", "MULTI")
Request:addRule(Rules.InventoryRules.isEmptySlot(1))
Request:addTask(Tasks.UtilTasks.message("MaterialError1"))
Request:addTask(Tasks.UtilTasks.message("MaterialError2"))
Request:addTask(Tasks.UtilTasks.waitForKey())

-- base

EnterBase = AIData:instance("base", "SINGLE", "MULTI")
EnterBase:addRule(Rules.MapRules.coord(0, 0, 0))
EnterBase:addTask(Tasks.TurtleTasks.turn("SOUTH"))
EnterBase:addTask(Tasks.TurtleTasks.move("FORWARD"))
EnterBase:addTask(Tasks.UtilTasks.saveCoord())
EnterBase:addTask(Tasks.UtilTasks.toConfigPos("Fuel"))
EnterBase:addTask(Tasks.InventoryTasks.supplyFuel())
EnterBase:addTask(Tasks.UtilTasks.toConfigPos("Material"))
EnterBase:addTask(Tasks.InventoryTasks.supply("material"))
EnterBase:addTask(Tasks.UtilTasks.moveBack())

Finish = AIData:instance("base", "AND", "MULTI")
Finish:addRule(Rules.MapRules.coord(0, 0, 1))
Finish:addRule(Rules.ParameterRules.parameter("finish", "==", true))
Finish:addTask(Tasks.TurtleTasks.turn("NORTH"))
Finish:addTask(Tasks.ParameterTasks.setState("exit"))

LeaveBase = AIData:instance("base", "SINGLE", "MULTI")
LeaveBase:addRule(Rules.MapRules.coord(0, 0, 1))
LeaveBase:addTask(Tasks.TurtleTasks.turn("NORTH"))
LeaveBase:addTask(Tasks.TurtleTasks.move("FORWARD"))
LeaveBase:addTask(Tasks.ParameterTasks.setState("move"))

-- move

MoveNorth = AIData:instance("move", "SINGLE", "MULTI", 50)
MoveNorth:addRule(Rules.ParameterRules.parameterI("coord.z", ">" ,"nextZ"))
MoveNorth:addTask(Tasks.TurtleTasks.turn("NORTH"))
MoveNorth:addTask(Tasks.TurtleTasks.move("FORWARD"))

MoveSouth = AIData:instance("move", "SINGLE", "MULTI", 50)
MoveSouth:addRule(Rules.ParameterRules.parameterI("coord.z", "<" ,"nextZ"))
MoveSouth:addTask(Tasks.TurtleTasks.turn("SOUTH"))
MoveSouth:addTask(Tasks.TurtleTasks.move("FORWARD"))

MoveEast = AIData:instance("move", "SINGLE", "MULTI")
MoveEast:addRule(Rules.ParameterRules.parameterI("coord.x", "<" ,"nextX"))
MoveEast:addTask(Tasks.TurtleTasks.turn("EAST"))
MoveEast:addTask(Tasks.TurtleTasks.move("FORWARD"))

MoveToReturn = AIData:instance("move", "SINGLE", "SINGLE", 100)
MoveToReturn:addRule(Rules.FuelRules.checkAndConsume(), false)
MoveToReturn:addTask(Tasks.ParameterTasks.setState("return"))

-- select

Select = AIData:instance("select", "AND", "MULTI")
Select:addRule(Rules.InventoryRules.hasItemI("material"))
Select:addRule(Rules.FuelRules.checkAndConsume())
Select:addTask(Tasks.InventoryTasks.selectByIndex("material"))
Select:addTask(Tasks.ParameterTasks.setState("retile"))

SelectToReturn = AIData:instance("select", "OR", "MULTI")
SelectToReturn:addRule(Rules.InventoryRules.hasItemI("material"), false)
SelectToReturn:addRule(Rules.FuelRules.checkAndConsume(), false)
SelectToReturn:addTask(Tasks.ParameterTasks.setState("return"))

-- retile

Retile = AIData:instance("retile", "SINGLE", "MULTI")
Retile:addRule(Rules.TurtleRules.compare("DOWN"), false)
Retile:addTask(Tasks.TurtleTasks.dig("DOWN"))
Retile:addTask(Tasks.TurtleTasks.place("DOWN"))
Retile:addTask(Tasks.ParameterTasks.setState("next"))

Ignore = AIData:instance("retile", "SINGLE", "MULTI")
Ignore:addRule(Rules.TurtleRules.compare("DOWN"))
Ignore:addTask(Tasks.ParameterTasks.setState("next"))

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
ReturnToHome:addRule(Rules.MapRules.coord(0, 0, 0))
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
WorkEnd1:addTask(Tasks.ParameterTasks.setData("finish", true))
WorkEnd1:addTask(Tasks.ParameterTasks.setState("return"))

WorkEnd2 = AIData:instance("next", "AND", "MULTI", 100)
WorkEnd2:addRule(Rules.ParameterRules.isOdd("range.maxWidth"))
WorkEnd2:addRule(Rules.ParameterRules.parameterI("nextX", "==", "range.maxWidth"))
WorkEnd2:addRule(Rules.ParameterRules.parameterI("nextZ", "==", "range.maxDepth"))
WorkEnd2:addTask(Tasks.ParameterTasks.setData("finish", true))
WorkEnd2:addTask(Tasks.ParameterTasks.setState("return"))
