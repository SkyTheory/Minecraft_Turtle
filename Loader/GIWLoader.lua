-- version = "1.02"

local GIWLoader = {}

local loadpath = {}
loadpath.root = "/"
loadpath.api = "/API/"
loadpath.event = "/API/Event/"
loadpath.inventory = "/API/Inventory"
loadpath.map = "/API/Map/"
loadpath.peripheral = "/API/Peripheral/"
loadpath.turtleex = "/API/TurtleEx/"
loadpath.util = "/API/Util/"
loadpath.debug = "/debug/"

local loadState = {}

local debugmessage1 = false
local debugmessage2 = false
local debugmessage3 = true

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
  if (debugmessage1) then
    tstr = table.concat(loadState.names, ", ")
    print(string.format("Names :%s", tstr))
  end
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
          if (debugmessage2) then
            print(string.format("Sorted %d :%s", #loadState.sortedNames, name))
          end
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
  if (debugmessage1) then
    tstr = table.concat(loadState.sortedNames, ", ")
    print(string.format("SortedNames :%s", tstr))
  end
end

function GIWLoader.postLoadAPI()
  local successAPI = {}
  local failedAPI = {}
  for i, path in ipairs(loadState.sortedPaths) do
    local name = loadState.sortedNames[i]
    local postLoadENV, apiENV = GIWLoader.makePostLoadENV()
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
    _ENV[name] = apiENV
  end
  if (debugmessage3) then
    print("API loading completed")
    print(string.format("%i / %i APIs loaded", #successAPI, #loadState.sortedNames))
    if (next(failedAPI)) then
      print(string.format("Failed :%s", table.concat(failedAPI, ", ")))
    end
  end
end

----------------------------------------

function GIWLoader.addAPI(rawname)
  local name, path = GIWLoader.getNameAndPath(rawname)
  table.insert(loadState.names, name)
  table.insert(loadState.paths, path)
  loadState.preLoading[name] = true
  if (debugmessage2) then
    print(string.format("Preload API :%s", name))
  end
end

function GIWLoader.getNameAndPath(rawname)
  local name = fs.getName(rawname)
  local path = GIWLoader.getPath(rawname)
  return name, path
end


function GIWLoader.getPath(name)
  for k, dir in next, loadpath do
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
  ENV.extends = function(apiname)
    ENV.dependency.after(apiname)
    ENV.dependency.require(apiname)
  end
  return ENV
end

function GIWLoader.makePostLoadENV()
  local ENV = {}
  local apiENV = {}
  local dummy = function() end
  ENV.dependency = {}
  ENV.dependency.require = dummy
  ENV.dependency.after = dummy
  ENV.dependency.before = dummy
  ENV.extends = function(classname)
    local superclass = _ENV[classname]
    ENV.super = superclass
    setmetatable(apiENV, {index = superclass})
  end
  setmetatable(ENV, {__index = _ENV})
  apiENV.instance = GIWLoader.instance
  apiENV.constructor = dummy
  return ENV, apiENV
end

function GIWLoader.instance(self, ...)
  local obj = {}
  obj.fields = {}
  obj.super = {}
  setmetatable(obj, {__index = GIWLoader.indexHandler(obj.fields, self), __newindex = obj.fields})
  setmetatable(obj.super, {__index = GIWLoader.indexHandler(obj.fields, self.super), __newindex = obj.fields})
  obj:constructor(...)
  return obj
end

function GIWLoader.indexHandler(...)
  -- returns A[key] or B[key] or C[key] or...
  local itbl = {...}
  return function(t, k)
    for ii, iv in next, itbl do
      if (iv[k] ~= nil) then
        return iv[k]
      end
    end
    return nil
  end
end

return GIWLoader.loadAPI
