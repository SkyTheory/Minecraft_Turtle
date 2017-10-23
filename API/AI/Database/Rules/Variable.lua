version = 1.10

requireAPI()

function firstTask(info)
  return (#info.eventLog == 0)
end

------------

function data(index, var)
  return function(info)
    return (GIWUtil.getByIndex(info.fields, index) == var)
  end
end

function compareIndexIndex(index1, op, index2)
  return function(info)
    local var1 = GIWUtil.getByIndex(info.fields, index1)
    local var2 = GIWUtil.getByIndex(info.fields, index2)
    return compare(var1, op, var2)
  end
end

function compareIndexValue(index, op, var)
  return function(info)
    local var1 = GIWUtil.getByIndex(info.fields, index)
    local var2 = var
    return compare(var1, op, var2)
  end
end

function chain(key)
  return function(info)
    local prev = info.eventLog[#info.eventLog]
    if (not prev) then return false end
    return (prev == key)
  end
end

------------

function compare(var1, op, var2)
  if (op == "==") then
    return (var1 == var2)
  end
  if (op == "~=") then
    return (var1 ~= var2)
  end
  if (op == "<") then
    return (var1 < var2)
  end
  if (op == "<=") then
    return (var1 < var2)
  end
  if (op == ">") then
    return (var1 < var2)
  end
  if (op == ">=") then
    return (var1 < var2)
  end
end
