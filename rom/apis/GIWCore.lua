version = "2.30"

local loadpath = {}
loadpath[1] = "/rom/GIW/API"
loadpath[2] = "/rom/GIW/TurtleAPI"

local path = "/rom/GIW"

-- API loading

loadAPI = loadfile("rom/GIW/Core/GIWLoader.lua", _ENV)()

function loadAllAPI()
  local index = {}
  addList(index, loadpath[1])
  if (turtle) then
    addList(index, loadpath[2])
  end
  GIWCore.loadAPI(unpack(index))
end

function addList(index, path)
  for k, v in next, fs.list(path) do
    local dir = fs.combine(path, v)
    if (fs.isDir(dir)) then
      for k2, v2 in next, fs.list(dir) do
        if (not fs.isDir(fs.combine(dir, v2))) then
          local name = string.gsub(v2, ".lua$", "")
          name = string.gsub(name, ".txt$", "")
          table.insert(index, name)
        end
      end
    else
      addList(index, dir)
    end
  end
end

-- Util

function setValue(key, var)
  _ENV[key] = var
end

function colorText(str, c)
  if (term.isColor()) then
    term.setTextColor(c)
    print(str)
    term.setTextColor(colors.white)
  else
    print(str)
  end
end

function indexHandler(...)
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
