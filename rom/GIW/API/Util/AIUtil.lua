version = "1.00"

dependency.require()
dependency.after()
dependency.before()

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
    return (var1 <= var2)
  end
  if (op == ">") then
    return (var1 > var2)
  end
  if (op == ">=") then
    return (var1 >= var2)
  end
  error("Invalid operator")
end
