local args = {...}
if (#args ~= 2) then
  print("Usage: TurtleAI <AI> <log>")
else
  loadfile("/API/GIWCore.lua", _ENV)()
  GIWCore.loadAllAPI()
  AILoader.loadAI(args[1])
  TurtleAI.engine(args[2])
end
