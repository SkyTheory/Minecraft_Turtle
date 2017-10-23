local args = {...}
local ainame
loadfile("/API/GIWCore.lua", _ENV)()
GIWCore.loadAllAPI()
local list = fs.list("/AI/")
local names = {}
for i, name in ipairs(list) do
  if (not fs.isDir(string.format("/AI/%s", name))) then
    local an = string.gsub(name, ".lua$", "")
    names[an] = true
    list[i] = an
  end
end
if (type(args[1]) == "string") then
   if (names[args[1]]) then
     ainame = args[1]
   end
end
if (ainame == nil) then
  ainame = SelectorUtil.selector("AI", list)
end
AILoader.loadAI(ainame)
TurtleAI.engine(ainame)
