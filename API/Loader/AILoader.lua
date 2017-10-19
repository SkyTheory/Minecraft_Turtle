version = "1.10"

dependency.require("GIWUtil", "TurtleAI", "AIData", "AIDatabase")
dependency.after("GIWUtil", "TurtleAI", "AIData", "AIDatabase")
dependency.before()

local path = "/API/AI/Database/"
local datas = {}
local AIpath = "/AI"
local init = false

function loadAI(name)
  if (not init) then
    readData()
  end
  local env = {}
  setmetatable(env, {__index = GIWCore.indexHandler(datas, _ENV)})
  local func, err = loadfile(string.format("%s.lua", fs.combine(AIpath, name)), env)
  if (not func) then
    GIWUtil.colorText(string.format("AILoader: Error loading module: %s", name), colors.red)
    GIWUtil.colorText(err, colors.red)
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
    end
  end
end

function readData()
  local pathlist = fs.list(path)
  local isError = false
  for i, adir in ipairs(pathlist) do
    local cpath = fs.combine(path, adir)
    local names = fs.list(cpath)
    datas[adir] = {}
    for i, rname in ipairs(names) do
      local filepath = fs.combine(cpath, rname)
      local env = {}
      local name = string.gsub(fs.getName(rname), ".lua", "")
      env.requireAPI = GIWCore.loadAPI
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
