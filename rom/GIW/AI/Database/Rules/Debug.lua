version = 1.00

function dummy(info)
  return true
end

------------

function printT(str)
  return function(info)
    print(str)
    return true
  end
end

function printF(str)
  return function(info)
    print(str)
    return false
  end
end

function check(func, str)
  return function(info)
    local flag = func(info)
    print(str, flag)
    return flag
  end
end
