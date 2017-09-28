-- version = 1.00

function enterBase(info)
  return (info.coord.x == 0 and info.coord.y == 0 and info.coord.z == 0)
end

function leaveBase(info)
  return (info.coord.x == 0 and info.coord.y == 0 and info.coord.z == 1)
end
