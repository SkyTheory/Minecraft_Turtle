-- version = "1.40"

local GIWLoader = {}

local loadpath = {}
loadpath[1] = "/rom/GIW/API"
loadpath[2] = "/rom/GIW/TurtleAPI"

local loadState = {}
local loaded = {}
local dummy = function() end

local debugmessage = true

function GIWLoader.loadAPI(...)
  loadState.names = {}
  loadState.paths = {}
  loadState.preLoading = {}
  loadState.wait = {}
  loadState.sortedNames = {}
  loadState.sortedPaths = {}
  loadState.loading = {}
  GIWLoader.getAPIList(...)
  GIWLoader.preLoadAPI()
  GIWLoader.sortAPIList()
  GIWLoader.postLoadAPI()
end

function GIWLoader.getAPIList(...)
  local rawnames = {...}
  for index, rawname in ipairs({...}) do
    GIWLoader.addAPI(rawname)
  end
end

function GIWLoader.preLoadAPI()
  for index, path in ipairs(loadState.paths) do
    -- Require API -> insert tables
    local preLoadENV = GIWLoader.makePreLoadENV(loadState.names[index])
    local apifunc = loadfile(path, preLoadENV)
    local success, err = pcall(apifunc)
  end
end

function GIWLoader.sortAPIList()
  local allLoaded = false
  while(not allLoaded) do
    local anyLoaded = false
    for i, name in ipairs(loadState.names) do
      if (not loadState.loading[name]) then
        local load = true
        -- Checking wait API (dependency)
        if (loadState.wait[name]) then
          for waitname, v in next, loadState.wait[name] do
            if (loadState.preLoading[waitname] and not loadState.loading[waitname]) then
              load = false
            end
          end
        end
        -- Sort API
        if (load) then
          local path = loadState.paths[i]
          table.insert(loadState.sortedNames, name)
          table.insert(loadState.sortedPaths, path)
          loadState.loading[name] = true
          anyLoaded = true
        end
      end
    end
    -- Failed to sort API
    if (not anyLoaded) then
      if (#loadState.names == #loadState.sortedNames) then
        allLoaded = true
      else
        local eAPIs = {}
        for i, name in ipairs(loadState.names) do
          if (not loadState.loading[name]) then
            table.insert(eAPIs, name)
          end
        end
        local eAPImsg = table.concat(eAPIs, ", ")
        local msg = string.format("Loop in dependency :%s", eAPImsg)
        GIWCore.colorText(msg, colors.red)
        error()
      end
    end
  end
end

function GIWLoader.postLoadAPI()
  local successAPI = {}
  local failedAPI = {}
  for i, path in ipairs(loadState.sortedPaths) do
    local name = loadState.sortedNames[i]
    local postLoadENV, apiENV = GIWLoader.makePostLoadENV(name)
    local apifunc, err = loadfile(path, postLoadENV)
    if (err) then
      GIWCore.colorText(err, colors.red)
    end
    local success, err = pcall(apifunc)
    if (success) then
    table.insert(successAPI, name)
      for k, v in next, postLoadENV do
        if (k ~= _ENV and k ~= dependency and k ~= extends) then
          apiENV[k] = v
        end
      end
    else
      table.insert(failedAPI, name)
      if (apifunc) then
        GIWCore.colorText(err, colors.red)
      end
    end
    _G[name] = apiENV
    loaded[name] = true
  end
  if (debugmessage) then
    if (#loadState.sortedNames > 0) then
      print("API loading complete")
      print(string.format("%i / %i APIs loaded", #successAPI, #loadState.sortedNames))
      if (next(failedAPI)) then
        print(string.format("Failed :%s", table.concat(failedAPI, ", ")))
        error()
      end
    end
  end
end

----------------------------------------

function GIWLoader.addAPI(rawname)
  local name, path = GIWLoader.getNameAndPath(rawname)
  if (not loaded[name]) then
    table.insert(loadState.names, name)
    table.insert(loadState.paths, path)
    loadState.preLoading[name] = true
  end
end

function GIWLoader.getNameAndPath(rawname)
  local name = fs.getName(rawname)
  local path = GIWLoader.getPath(rawname)
  return name, path
end


function GIWLoader.getPath(name)
  local dloadpath = {}
  for i, rd in ipairs(loadpath) do
    for i, v in ipairs(fs.list(rd)) do
      local path = fs.combine(rd, v)
      if (fs.isDir(path)) then
        table.insert(dloadpath, path)
      end
    end
  end
  for k, dir in next, dloadpath do
    local path = fs.combine(dir, name)
    if (fs.exists(path) and not fs.isDir(path)) then
      return path
    end
    local path = string.format("%s.lua", path)
    if (fs.exists(path) and not fs.isDir(path)) then
      return path
    end
  end
  GIWCore.colorText(string.format("File not found :%s", name), colors.red)
  error()
  return nil
end

----------------------------------------

function GIWLoader.makePreLoadENV(apiname)
  local ENV = {}
  ENV.dependency = {}
  ENV.dependency.require = function(...)
    for index, rawname in ipairs({...}) do
      local name = fs.getName(rawname)
      if (not loadState.preLoading[name]) then
        GIWLoader.addAPI(name)
      end
    end
  end
  ENV.dependency.after = function(...)
    loadState.wait[apiname] = loadState.wait[apiname] or {}
    for index, rawname in ipairs({...}) do
      loadState.wait[apiname][fs.getName(rawname)] = true
    end
  end
  ENV.dependency.before = function(...)
    for index, rawname in ipairs({...}) do
      local name = fs.getName(rawname)
      loadState.wait[name] = loadState.wait[name] or {}
      loadState.wait[name][apiname] = true
    end
  end
  ENV.extends = dummy
  return ENV
end

function GIWLoader.makePostLoadENV(name)
  local ENV = {}
  local apiENV = {}
  ENV.dependency = {}
  ENV.dependency.require = dummy
  ENV.dependency.after = dummy
  ENV.dependency.before = dummy
  ENV.extends = function(class)
    ENV.super = _ENV[class]
    setmetatable(apiENV, {__index = _ENV[class]})
    if (ENV.super.constructor) then
      apiENV.constructor = ENV.super.constructor
    end
  end
  ENV.class = GIWLoader.class
  ENV[name] = apiENV
  setmetatable(ENV, {__index = _ENV})
  apiENV.classname = name
  apiENV.instance = GIWLoader.instance
  apiENV.instanceof = GIWLoader.instanceof
  apiENV.constructor = dummy
  return ENV, apiENV
end

function GIWLoader.class()
  local obj = {}
  obj.instance = GIWLoader.instance
  obj.constructor = dummy
  obj.extends = GIWLoader.extends
  return obj
end

function GIWLoader.extends(self, class)
  self.super = class
  setmetatable(self, {__index = class})
end


function GIWLoader.instance(self, ...)
  local obj = {}
  obj.classname = self.classname
  obj.fields = {}
  obj.super = {}
  setmetatable(obj, {__index = GIWCore.indexHandler(obj.fields, self), __newindex = obj.fields})
  setmetatable(obj.super, {__index = GIWCore.indexHandler(obj.fields, self.super), __newindex = obj.fields})
  obj:constructor(...)
  return obj
end

function GIWLoader.instanceof(obj, class)
  if (obj.classname == class.classname) then return true end
  if (obj.super and obj.super.classname) then
    return GIWLoader.instanceof(obj.super, class)
  end
  return false
end

return GIWLoader.loadAPI
