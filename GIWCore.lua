version = "2.20"

local GIWCore = {}
_ENV.GIWCore = GIWCore

local loadpath = fs.list("/API")

-- API loading

GIWCore.loadAPI = loadfile("/API/Loader/GIWLoader.lua", _ENV)()

function GIWCore.getLoadPath()
  return loadpath
end

function GIWCore.loadAllAPI()
  local index = {}
  -- Do not read sub directory
  for k, v in next, fs.list("/API") do
    local dir = fs.combine("/API", v)
    if (fs.isDir(dir)) then
      for k2, v2 in next, fs.list(dir) do
        if (not fs.isDir(fs.combine(dir, v2))) then
          local name = string.gsub(v2, ".lua", "")
          name = string.gsub(name, ".txt", "")
          if (name ~= "GIWLoader") then
          table.insert(index, name)
        end
      end
    end
  end
  GIWCore.loadAPI(unpack(index))
end

-- Util

function GIWCore.setValue(key, var)
  _ENV[key] = var
end

function GIWCore.colorText(str, c)
  if (term.isColor()) then
    term.setTextColor(c)
    print(str)
    term.setTextColor(colors.white)
  else
    print(str)
  end
end

function GIWCore.indexHandler(...)
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
