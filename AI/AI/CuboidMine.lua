local version = "1.00"

dependency.require("Knowledge", "KnowledgeBase")
dependency.after("Knowledge", "KnowledgeBase")
dependency.before()

local trigger = Knowledge.getTriggerList()
local act = Knowledge.getActList()

-- State: init

local initCoord = Knowledge:instance(
  trigger.Basic.hasNotKey("coord"),
  act.Basic.initCoord(0, 0, 1, "NORTH"),
  100
)

local initMap = Knowledge:instance(
  trigger.Basic.hasNotKey("map"),
  act.Basic.initMap,
  90
)

local initRange = Knowledge:instance(
  trigger.Basic.hasNotKey("range"),
  act.Cuboid.setRange,
  80
)

local initY = Knowledge:instance(
  trigger.Basic.hasNotKey("initY"),
  act.Descent.initNextY,
  70
)

-- State: base

local enterBase = Knowledge:instance(
  trigger.Cuboid.enterBase,
  act.Basic.moveSouth,
  100
)

local unload = Knowledge:instance(
  trigger.Basic.chain(enterBase),
  act.Basic.unload,
  150
)

local supply = Knowledge:instance(
  trigger.Basic.chain(unload),
  act.Basic.supply,
  150
)

local leaveBase = Knowledge:instance(
  trigger.Cuboid.leaveBase,
  act.Basic.moveNorth,
  100
)

enterBase:addTrigger(trigger.Basic.reverse(trigger.Basic.chain(leaveBase)))

-- State: descent

local moveDown = Knowledge:instance(
  trigger.Descent.descent,
  act.Basic.moveDown,
  100
)

local updateNextY = Knowledge:instance(
  trigger.Descent.updateNextY,
  act.Descent.updateNextY,
  100
)

local reachFloor = Knowledge:instance(
  trigger.Descent.reachFloor,
  act.Descent.reachFloor,
  100
)

-- State: prework

local dummy = Knowledge:instance(
  trigger.Basic.dummyT,
  function() error("Stop!") end,
  math.huge
)

-- Registration

KnowledgeBase.addStatus("base")
KnowledgeBase.addStatus("descent")
KnowledgeBase.addStatus("prework")
KnowledgeBase.addStatus("work")
KnowledgeBase.addStatus("postwork")
KnowledgeBase.addStatus("ascent")

initCoord:register("init")
initMap:register("init")
initRange:register("init")
initY:register("init")
enterBase:register("base")
unload:register("base")
supply:register("base")
leaveBase:register("base")
moveDown:register("descent")
updateNextY:register("descent")
reachFloor:register("descent")
dummy:register("prework")
