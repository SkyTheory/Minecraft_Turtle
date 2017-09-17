version = "2.10"

local GIWCore = {}
_ENV.GIWCore = GIWCore

local loading = {GIWCore = GIWCore}
local loaded = {GIWCore = GIWCore}
local loadstack = {}

-- API loading

GIWCore.loadAPI = require("/API/Loader/GIWLoader")

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
