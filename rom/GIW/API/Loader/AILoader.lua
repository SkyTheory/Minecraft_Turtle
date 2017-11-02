version = "1.20"

dependency.require("GIWUtil", "TurtleAI", "AIData", "AIDatabase")
dependency.after("GIWUtil", "TurtleAI", "AIData", "AIDatabase")
dependency.before()

local datas = {}
local database = "/rom/GIW/AI/Database"
local cpath = "/rom/GIW/AI/Computer"
local tpath = "/rom/GIW/AI/Turtle"
local init = false

function loadAI(name)
  local path
  local isError = false
  if (turtle) then
    path = tpath
  else
    path = cpath
  end
  if (not init) then
    readData()
  end
  local env = {}
  setmetatable(env, {__index = GIWCore.indexHandler(datas, _ENV)})
  local func, err = loadfile(string.format("%s.lua", fs.combine(path, name)), env)
  if (not func) then
    GIWUtil.colorText(string.format("AILoader: Error loading module: %s", name), colors.red)
    GIWUtil.colorText(err, colors.red)
    isError = true
  else
    local ok, err = pcall(func)
    if (ok) then
      if (env.conflict) then
        AIDatabase.setResolveRule(env.conflict)
      end
      for i, v in ipairs(env.status) do
        AIDatabase.addStatus(v)
      end
      for k, v in next, env do
        if (type(v) == "table" and v.instanceof and v:instanceof(AIData)) then
          v.key = k
          AIDatabase.addData(v)
        end
      end
      TurtleAI.registerAI(name)
    else
      GIWUtil.colorText(string.format("AILoader: Error loading module: %s", name), colors.red)
      GIWUtil.colorText(err, colors.red)
      isError = true
    end
  end
  if (isError) then
    error()
  end
end

function readData()
  GIWCore.loadAllAPI()
  local isError = false
  for i, adir in ipairs(fs.list(database)) do
    local cpath = fs.combine(database, adir)
    local names = fs.list(cpath)
    datas[adir] = {}
    for i, rname in ipairs(names) do
      local filepath = fs.combine(cpath, rname)
      local env = {}
      local name = string.gsub(fs.getName(rname), ".lua", "")
      setmetatable(env, {__index = _ENV})
      if (not fs.isDir(filepath)) then
        local func, err = loadfile(filepath, env)
        if (not func) then
          GIWUtil.colorText(string.format("AILoader: Error loading module: %s/%s", adir, rname), colors.red)
          GIWUtil.colorText(err, colors.red)
          isError = true
        else
          local ok, err = pcall(func)
          if (ok) then
            datas[adir][name] = {}
            for k, v in next, env do
              if (type(v) == "function") then
                datas[adir][name][k] = v
              end
            end
          else
            GIWUtil.colorText(string.format("AILoader: Error loading module: %s/%s", adir, rname), colors.red)
            GIWUtil.colorText(err, colors.red)
            isError = true
          end
        end
      end
    end
  end
  if (isError) then
    error()
  else
    init = true
  end
end
