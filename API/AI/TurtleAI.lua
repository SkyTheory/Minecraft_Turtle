local version = "1.02"

dependency.require("AIDatabase", "Information")
dependency.after("AIDatabase", "Information")
dependency.before()

local loadedAI = {}

local debugmessage = true

function engine(logpath, isResume)
  if (not fs.exists("startup")) then
    createStartUpFile(logpath)
  end
  local info = Information:instance(logpath)
  while(info.state ~= "exit") do
    getNext(info)
    if (info.nextkey) then
      AIDatabase.execute(info, info.nextkey)
      table.insert(info.eventLog, info.nextkey)
      info.nextkey = nil
      info:saveLog()
    else
      break
    end
  end
  info:saveLog()
  info:backupLog()
  if (debugmessage) then
    print("AI tasks complete.")
    print(string.format("Day - %i Time - %f", os.day(), os.time()))
  end
  info:simplificationLog()
  fs.delete("startup")
end

function getNext(info)
  local state = info.state
  while(info.nextkey == nil) do
    info.nextkey = AIDatabase.match(info)
    if (not info.nextkey) then
      info.state = AIDatabase.getNextState(info.state)
      if (info.state == state) then
        GIWUtil.colorText("No valid data", colors.red)
        break
      end
      if (state == "init") then
        state = AIDatabase.getNextState("init")
      end
    end
  end
end

function registerAI(name)
  table.insert(loadedAI, name)
end

function createStartUpFile(logpath)
  local path = logpath or ""
  local file = fs.open("startup", "w")
  file.writeLine("loadfile(\"/API/GIWCore.lua\", _ENV)()")
  file.writeLine("GIWCore.loadAllAPI()")
  for i, v in ipairs(loadedAI) do
    file.writeLine(string.format("AILoader.loadAI(\"%s\")", v))
  end
  file.writeLine(string.format("TurtleAI.engine(\"%s\")", path))
  file.close()
end
