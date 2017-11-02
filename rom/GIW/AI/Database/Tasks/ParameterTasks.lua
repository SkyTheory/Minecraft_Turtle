version = 1.15

function setRange2D(pw, pd)
  return function(info)
    info.range = SelectorUtil.range2D(pw, pd)
  end
end

function setRange3D(pw, pd, ph)
  return function(info)
    info.range = SelectorUtil.range3D(pw, pd, ph)
  end
end

function setState(s)
  return function(info)
    info.state = s
  end
end

function setData(index, v)
  return function(info)
    GIWUtil.setByIndex(info.fields, index, v)
  end
end

function addData(index, v)
  return function(info)
    local var = GIWUtil.getByIndex(info.fields, index)
    GIWUtil.setByIndex(info.fields, index, var + v)
  end
end

function addDataI(index1, index2)
  return function(info)
    local var1 = GIWUtil.getByIndex(info.fields, index1)
    local var2 = GIWUtil.getByIndex(info.fields, index2)
    GIWUtil.setByIndex(info.fields, index1, var1 + var2)
  end
end

function selectData(index, key, list)
  return function(info)
    local var = SelectorUtil.selector(key, list)
    GIWUtil.setByIndex(info.fields, index, var)
  end
end

function selectNumber(index, key, ctype)
  return function(info)
    local var = SelectorUtil.number(key, ctype)
    GIWUtil.setByIndex(info.fields, index, var)
  end
end

function subData(index, v)
  return function(info)
    local var = GIWUtil.getByIndex(info.fields, index)
    GIWUtil.setByIndex(info.fields, index, var - v)
  end
end

function subDataI(index1, index2)
  return function(info)
    local var1 = GIWUtil.getByIndex(info.fields, index1)
    local var2 = GIWUtil.getByIndex(info.fields, index2)
    GIWUtil.setByIndex(info.fields, index1, var1 - var2)
  end
end

function copyData(fromindex, toindex)
  return function(info)
    local data = GIWUtil.getByIndex(info.fields, fromindex)
    GIWUtil.setByIndex(info.fields, toindex, data, true)
  end
end

function setTemporaryData(key)
  return function(info)
    info:setTemporaryData(key)
  end
end
