version = 1.00

function pulse(dir)
  return function(info)
    RedstoneUtil.pulse(dir)
  end
end
