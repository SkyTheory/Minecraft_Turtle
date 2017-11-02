version = "1.01"

status = {}
status[1] = "base"
status[2] = "turn"
status[3] = "move"
status[4] = "detour"
status[5] = "harvest"
status[6] = "plant"
status[7] = "next"
status[8] = "return"
status[9] = "returnmove"

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

-- base

EnterBase = AIData:instance("base", "SINGLE", "MULTI")
EnterBase:addRule(Rules.MapRules.coord(0, 1, 0))
EnterBase:addTask(Tasks.TurtleTasks.turn("SOUTH"))
EnterBase:addTask(Tasks.TurtleTasks.move("FORWARD"))
EnterBase:addTask(Tasks.UtilTasks.saveCoord())
EnterBase:addTask(Tasks.UtilTasks.toConfigPos("Unload"))
EnterBase:addTask(Tasks.CropTasks.unloadCrops())
EnterBase:addTask(Tasks.UtilTasks.toConfigPos("Fuel"))
EnterBase:addTask(Tasks.InventoryTasks.supplyFuel())
EnterBase:addTask(Tasks.UtilTasks.moveBack())

Restart = AIData:instance("base", "AND", "MULTI", 100)
Restart:addRule(Rules.MapRules.coord(0, 1, 1))
Restart:addRule(Rules.ParameterRules.parameter("restart", "==", true))
Restart:addTask(Tasks.ParameterTasks.setData("restart", "==", false))
Restart:addTask(Tasks.ParameterTasks.setData("nextX", 0))
Restart:addTask(Tasks.ParameterTasks.setData("nextZ", 0))
Restart:addTask(Tasks.UtilTasks.sleepI("stime"))

LeaveBase = AIData:instance("base", "SINGLE", "SINGLE")
LeaveBase:addRule(Rules.MapRules.coord(0, 1, 1))
LeaveBase:addTask(Tasks.ParameterTasks.setState("turn"))

-- turn

TurnNorth = AIData:instance("turn", "SINGLE", "MULTI", 50)
TurnNorth:addRule(Rules.ParameterRules.parameterI("coord.z", ">" ,"nextZ"))
TurnNorth:addTask(Tasks.TurtleTasks.turn("NORTH"))
TurnNorth:addTask(Tasks.ParameterTasks.setState("move"))

TurnSouth = AIData:instance("turn", "SINGLE", "MULTI", 50)
TurnSouth:addRule(Rules.ParameterRules.parameterI("coord.z", "<" ,"nextZ"))
TurnSouth:addTask(Tasks.TurtleTasks.turn("SOUTH"))
TurnSouth:addTask(Tasks.ParameterTasks.setState("move"))

TurnEast = AIData:instance("turn", "SINGLE", "MULTI")
TurnEast:addRule(Rules.ParameterRules.parameterI("coord.x", "<" ,"nextX"))
TurnEast:addTask(Tasks.TurtleTasks.turn("EAST"))
TurnEast:addTask(Tasks.ParameterTasks.setState("move"))

TurnToReturn = AIData:instance("turn", "SINGLE", "SINGLE", 100)
TurnToReturn:addRule(Rules.FuelRules.checkAndConsume(), false)
TurnToReturn:addTask(Tasks.ParameterTasks.setState("return"))

-- move

Move = AIData:instance("move", "SINGLE", "MULTI")
Move:addRule(Rules.TurtleRules.detect("FORWARD"), false)
Move:addTask(Tasks.TurtleTasks.move("FORWARD"))
Move:addTask(Tasks.TurtleTasks.suck("DOWN"))
Move:addTask(Tasks.ParameterTasks.setState("harvest"))

-- detour

Detour = AIData:instance("detour", "SINGLE", "MULTI")
Detour:addRule(Rules.TurtleRules.detect("FORWARD"))
Detour:addTask(Tasks.TurtleTasks.move("UP"))
Detour:addTask(Tasks.ParameterTasks.setState("move"))

-- harvest

HarvestAndPlant = AIData:instance("harvest", "AND", "MULTI", 50)
HarvestAndPlant:addRule(Rules.MapRules.yCoord(1))
HarvestAndPlant:addRule(Rules.CropRules.isHarvestable("DOWN", true, true))
HarvestAndPlant:addTask(Tasks.TurtleTasks.dig("DOWN"))
HarvestAndPlant:addTask(Tasks.TurtleTasks.suck("DOWN"))
HarvestAndPlant:addTask(Tasks.TurtleTasks.place("DOWN"))
HarvestAndPlant:addTask(Tasks.ParameterTasks.setState("next"))

HarvestAndDown = AIData:instance("harvest", "AND", "MULTI", 150)
HarvestAndDown:addRule(Rules.MapRules.yCoord(1), false)
HarvestAndDown:addRule(Rules.CropRules.isHarvestable("DOWN"))
HarvestAndDown:addTask(Tasks.TurtleTasks.move("DOWN"))

DownWithoutHarvest = AIData:instance("harvest", "AND", "SINGLE", 100)
DownWithoutHarvest:addRule(Rules.MapRules.yCoord(1), false)
DownWithoutHarvest:addRule(Rules.TurtleRules.detect("DONW"), false)
DownWithoutHarvest:addTask(Tasks.TurtleTasks.move("DOWN"))

Continue = AIData:instance("harvest", "AND", "SINGLE")
Continue:addRule(Rules.MapRules.yCoord(1))
Continue:addTask(Tasks.ParameterTasks.setState("next"))

-- next

NextNorth = AIData:instance("next", "AND", "MULTI", 50)
NextNorth:addRule(Rules.ParameterRules.isEven("nextX"))
NextNorth:addRule(Rules.ParameterRules.parameterI("nextZ", ">", "range.minDepth"))
NextNorth:addTask(Tasks.ParameterTasks.subData("nextZ", 1))
NextNorth:addTask(Tasks.ParameterTasks.setState("turn"))

NextSouth = AIData:instance("next", "AND", "MULTI", 50)
NextSouth:addRule(Rules.ParameterRules.isOdd("nextX"))
NextSouth:addRule(Rules.ParameterRules.parameterI("nextZ", "<", "range.maxDepth"))
NextSouth:addTask(Tasks.ParameterTasks.addData("nextZ", 1))
NextSouth:addTask(Tasks.ParameterTasks.setState("turn"))

NextEast = AIData:instance("next", "OR", "MULTI")
NextEast:addRule(Rules.ParameterRules.parameterI("nextZ", "==", "range.minDepth"))
NextEast:addRule(Rules.ParameterRules.parameterI("nextZ", "==", "range.maxDepth"))
NextEast:addTask(Tasks.ParameterTasks.addData("nextX", 1))
NextEast:addTask(Tasks.ParameterTasks.setState("turn"))

WorkEnd1 = AIData:instance("next", "AND", "MULTI", 150)
WorkEnd1:addRule(Rules.ParameterRules.isEven("range.maxWidth"))
WorkEnd1:addRule(Rules.ParameterRules.parameterI("nextX", "==", "range.maxWidth"))
WorkEnd1:addRule(Rules.ParameterRules.parameterI("nextZ", "==", "range.minDepth"))
WorkEnd1:addTask(Tasks.ParameterTasks.setData("restart", true))
WorkEnd1:addTask(Tasks.ParameterTasks.setState("return"))

WorkEnd2 = AIData:instance("next", "AND", "MULTI", 150)
WorkEnd2:addRule(Rules.ParameterRules.isOdd("range.maxWidth"))
WorkEnd2:addRule(Rules.ParameterRules.parameterI("nextX", "==", "range.maxWidth"))
WorkEnd2:addRule(Rules.ParameterRules.parameterI("nextZ", "==", "range.maxDepth"))
WorkEnd2:addTask(Tasks.ParameterTasks.setData("restart", true))
WorkEnd2:addTask(Tasks.ParameterTasks.setState("return"))

CheckState = AIData:instance("next", "OR", "SINGLE", 100)
CheckState:addRule(Rules.FuelRules.checkAndConsume, false)
CheckState:addRule(Rules.InventoryRules.hasEmptySlotCount(2), false)
CheckState:addTask(Tasks.ParameterTasks.setState("return"))

-- return

ReturnWest = AIData:instance("return", "SINGLE", "MULTI", 75)
ReturnWest:addRule(Rules.ParameterRules.parameterI("coord.x", ">", "range.minWidth"))
ReturnWest:addTask(Tasks.TurtleTasks.turn("WEST"))
ReturnWest:addTask(Tasks.ParameterTasks.setState("returnmove"))

ReturnSouth = AIData:instance("return", "SINGLE", "MULTI", 50)
ReturnSouth:addRule(Rules.ParameterRules.parameterI("coord.z", "<", "range.maxDepth"))
ReturnSouth:addTask(Tasks.TurtleTasks.turn("SOUTH"))
ReturnSouth:addTask(Tasks.ParameterTasks.setState("returnmove"))

-- returnmove

ReturnMove = AIData:instance("returnmove", "OR", "MULTI")
ReturnMove:addRule(Rules.MapRules.xCoord(0), false)
ReturnMove:addRule(Rules.MapRules.zCoord(0), false)
ReturnMove:addTask(Tasks.TurtleTasks.move("FORWARD"))
ReturnMove:addTask(Tasks.ParameterTasks.setState("return"))

ReturnDetour = AIData:instance("returnmove", "SINGLE", "SINGLE", 50)
ReturnDetour:addRule(Rules.TurtleRules.detect("FORWARD"))
ReturnDetour:addTask(Tasks.TurtleTasks.move("UP"))

ReturnDescent = AIData:instance("returnmove", "AND", "SINGLE", 100)
ReturnDescent:addRule(Rules.MapRules.xCoord(0))
ReturnDescent:addRule(Rules.MapRules.zCoord(0))
ReturnDescent:addTask(Tasks.TurtleTasks.move("DOWN"))

ReturnToHome = AIData:instance("returnmove", "SINGLE", "SINGLE", 150)
ReturnToHome:addRule(Rules.MapRules.coord(0, 1, 0))
ReturnToHome:addTask(Tasks.ParameterTasks.setState("base"))
