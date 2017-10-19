version = 1.00

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

function referInfo(index1, index2)
  return function(info)
    return (GIWUtil.getByIndex(info.fields, index1) == GIWUtil.getByIndex(info.fields, index2))
  end
end

function chain(obj)
  return function(info)
    local prev = info.eventLog[#info.eventLog]
    if (not prev) then return false end
    return (prev == obj.key)
  end
end
