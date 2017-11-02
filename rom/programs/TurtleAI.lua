local args = {...}
local ainame
local clist = fs.list("/rom/GIW/AI/Computer")
local tlist = fs.list("/rom/GIW/AI/Turtle")
local namelist = {}
local names = {}

local list

if (turtle) then
  list = tlist
else
  list = clist
end

for i, name in ipairs(list) do
  if (not fs.isDir(fs.combine("/rom/GIW/AI", name))) then
    local an = string.gsub(name, ".lua$", "")
    names[an] = true
    table.insert(namelist, an)
  end
end
if (type(args[1]) == "string") then
  if (args[1] == "debug") then
    LogHandler.enabledebug()
    TurtleAI.enabledebug()
  end
  if (names[args[1]]) then
    ainame = args[1]
  end
end

if (ainame == nil) then
  ainame = SelectorUtil.selector("AI", namelist)
end
AILoader.loadAI(ainame)
TurtleAI.engine(ainame)
