version = "1.02"

status = {}
status[1] = "input"
status[2] = "grind"
status[3] = "draw"
status[4] = "mix"
status[5] = "output"

--conflict = "key"

-- init

Init = AIData:instance("init", "SINGLE", "MULTI")
Init:addRule(Rules.ParameterRules.firstTask())
Init:addTask(Tasks.TurtleTasks.requireCrafty())
Init:addTask(Tasks.ParameterTasks.selectData("shape", "shape", {"Baguette", "Bread", "Bun"}))
Init:addTask(Tasks.ParameterTasks.setData("stock", 0))
Init:addTask(Tasks.ParameterTasks.setTemporaryData("eventlog"))

InitBaguette = AIData:instance("init", "AND", "MULTI")
InitBaguette:addRule(Rules.ParameterRules.parameter("shape", "==", "Baguette"))
InitBaguette:addRule(Rules.ParameterRules.parameter("need", "==", nil))
InitBaguette:addTask(Tasks.ParameterTasks.setData("need", 3))
InitBaguette:addTask(Tasks.ParameterTasks.setState("input"))

InitBread = AIData:instance("init", "AND", "MULTI")
InitBread:addRule(Rules.ParameterRules.parameter("shape", "==", "Bread"))
InitBread:addRule(Rules.ParameterRules.parameter("need", "==", nil))
InitBread:addTask(Tasks.ParameterTasks.setData("need", 2))
InitBread:addTask(Tasks.ParameterTasks.setState("input"))

InitBun = AIData:instance("init", "AND", "MULTI")
InitBun:addRule(Rules.ParameterRules.parameter("shape", "==", "Bun"))
InitBun:addRule(Rules.ParameterRules.parameter("need", "==", nil))
InitBun:addTask(Tasks.ParameterTasks.setData("need", 1))
InitBun:addTask(Tasks.ParameterTasks.setState("input"))

-- input

TakeWheat = AIData:instance("input", "SINGLE", "MULTI")
TakeWheat:addRule(Rules.InventoryRules.hasItem("minecraft:wheat"), false)
TakeWheat:addTask(Tasks.InventoryTasks.select(1))
TakeWheat:addTask(Tasks.TurtleTasks.turn("WEST"))
TakeWheat:addTask(Tasks.TurtleTasks.suck("FORWARD", 1))

PutWheat = AIData:instance("input", "SINGLE", "MULTI")
PutWheat:addRule(Rules.InventoryRules.hasItem("minecraft:wheat", 2))
PutWheat:addTask(Tasks.InventoryTasks.selectByName("minecraft:wheat"))
PutWheat:addTask(Tasks.TurtleTasks.turn("WEST"))
PutWheat:addTask(Tasks.TurtleTasks.drop("FORWARD"))

-- grind

TakeMortar = AIData:instance("grind", "AND", "MULTI")
TakeMortar:addRule(Rules.InventoryRules.hasItem("minecraft:wheat"))
TakeMortar:addRule(Rules.InventoryRules.hasItem("gregtech:gt.metatool.01"), false)
TakeMortar:addTask(Tasks.TurtleTasks.turn("NORTH"))
TakeMortar:addTask(Tasks.TurtleTasks.suck("FORWARD", 1))

Grind = AIData:instance("grind", "AND", "MULTI")
Grind:addRule(Rules.InventoryRules.hasItem("minecraft:wheat"))
Grind:addRule(Rules.InventoryRules.hasItem("gregtech:gt.metatool.01"))
Grind:addTask(Tasks.TurtleTasks.craft())

putMortar = AIData:instance("grind", "AND", "MULTI")
putMortar:addRule(Rules.InventoryRules.hasItem("minecraft:wheat"), false)
putMortar:addRule(Rules.InventoryRules.hasItem("gregtech:gt.metatool.01"))
putMortar:addTask(Tasks.InventoryTasks.selectByName("gregtech:gt.metatool.01"))
putMortar:addTask(Tasks.TurtleTasks.turn("NORTH"))
putMortar:addTask(Tasks.TurtleTasks.drop("FORWARD"))

-- draw

TakeBucket = AIData:instance("draw", "AND", "MULTI")
TakeBucket:addRule(Rules.InventoryRules.hasItem("minecraft:water_bucket"), false)
TakeBucket:addTask(Tasks.RedstoneTasks.pulse("DOWN"))
TakeBucket:addTask(Tasks.TurtleTasks.suck("DOWN", 1))

PutBucket = AIData:instance("draw", "SINGLE", "MULTI")
PutBucket:addRule(Rules.InventoryRules.hasItem("minecraft:bucket"))
PutBucket:addTask(Tasks.InventoryTasks.selectByName("minecraft:bucket"))
PutBucket:addTask(Tasks.TurtleTasks.drop("DOWN"))

-- mix

Mix = AIData:instance("mix", "SINGLE", "MULTI")
Mix:addRule(Rules.InventoryRules.hasItem("gregtech:gt.metaitem.01"))
Mix:addTask(Tasks.TurtleTasks.craft())
Mix:addTask(Tasks.ParameterTasks.addData("stock", 1))
Mix:addTask(Tasks.InventoryTasks.selectByName("minecraft:bucket"))
Mix:addTask(Tasks.TurtleTasks.drop("DOWN"))

-- output

HasStock = AIData:instance("output", "AND", "MULTI")
HasStock:addRule(Rules.ParameterRules.parameterI("stock", "==", "need"))
HasStock:addRule(Rules.InventoryRules.hasItem("gregtech:gt.metaitem.02"))
HasStock:addRule(Rules.InventoryRules.hasItemCI("gregtech:gt.metaitem.02", "need"), false)
HasStock:addTask(Tasks.InventoryTasks.selectEmpty())
HasStock:addTask(Tasks.TurtleTasks.suck("UP", 1))

OutPut = AIData:instance("output", "AND", "MULTI")
OutPut:addRule(Rules.ParameterRules.parameterI("stock", "==", "need"))
OutPut:addRule(Rules.InventoryRules.hasItemCI("gregtech:gt.metaitem.02", "need"))
OutPut:addTask(Tasks.TurtleTasks.craft())
OutPut:addTask(Tasks.InventoryTasks.selectByName("gregtech:gt.metaitem.02"))
OutPut:addTask(Tasks.TurtleTasks.turn("EAST"))
OutPut:addTask(Tasks.TurtleTasks.drop("FORWARD"))
OutPut:addTask(Tasks.ParameterTasks.setData("stock", 0))
OutPut:addTask(Tasks.ParameterTasks.setState("input"))

HasNoStock = AIData:instance("output", "AND", "MULTI")
HasNoStock:addRule(Rules.ParameterRules.parameterI("stock", "~=", "need"))
HasNoStock:addRule(Rules.InventoryRules.hasItem("gregtech:gt.metaitem.02"))
HasNoStock:addTask(Tasks.InventoryTasks.selectByName("gregtech:gt.metaitem.02"))
HasNoStock:addTask(Tasks.TurtleTasks.drop("UP"))
HasNoStock:addTask(Tasks.ParameterTasks.setState("input"))
