version = "1.01"

dependency.require()
dependency.after()
dependency.before()

function pulse(d, time)
  local dir = fixDirection(d)
  redstone.setOutput(dir, false)
  redstone.setOutput(dir, true)
  os.sleep(time)
  redstone.setOutput(dir, false)
end

function clock(d, i1, i2, ...)
  local dir = fixDirection(d)
  local interval1 = i1 or 1
  local interval2 = i2 or interval1
  local rsclock = function()
    while(true) do
      redstone.setOutput(dir, true)
      os.sleep(interval1)
      redstone.setOutput(dir, false)
      os.sleep(interval2)
    end
  end
  parallel.waitForAny(rsclock, ...)
end

function fixDirection(dir)
  if (dir == "FORWARD") then return "front" end
  if (dir == "RIGHT") then return "right" end
  if (dir == "LEFT") then return "left" end
  if (dir == "BACK") then return "back" end
  if (dir == "UP") then return "top" end
  if (dir == "DOWN") then return "bottom" end
  return dir
end
