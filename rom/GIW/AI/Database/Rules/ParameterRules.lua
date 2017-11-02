version = 1.11

function firstTask()
  return function(info)
    return (#info.eventlog == 0)
  end
end

------------

function parameter(index, op, var)
  return function(info)
    local var1 = GIWUtil.getByIndex(info.fields, index)
    local var2 = var
    return AIUtil.compare(var1, op, var2)
  end
end

function parameterI(index1, op, index2)
  return function(info)
    local var1 = GIWUtil.getByIndex(info.fields, index1)
    local var2 = GIWUtil.getByIndex(info.fields, index2)
    return AIUtil.compare(var1, op, var2)
  end
end

function mod(index, mod, var)
  return function(info)
    local data = GIWUtil.getByIndex(info.fields, index)
    return (data % mod == var)
  end
end

function isEven(index)
  return mod(index, 2, 0)
end

function isOdd(index)
  return mod(index, 2, 1)
end
