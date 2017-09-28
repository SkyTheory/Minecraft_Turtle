-- version = 1.00

function initNextY(info)
  info.nextY = -2
  info.state = KnowledgeBase.getNextState(info.state)
end

function updateNextY(info)
  info.nextY = info.coord.y - 3
  info.state = KnowledgeBase.getNextState(info.state)
end

function reachFloor(info)
  info.nextY = info.coord.y
  info.state = KnowledgeBase.getNextState(info.state)
  info.bottom = true
end
