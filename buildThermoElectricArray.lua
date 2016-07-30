
-- this doesn't work. don't bother, tbh.
--package.path = package.path .. ";./packages/?.lua"
--require 'lemock'
--mc = lemock.controller()
--peripheral = mc:mock()
--turtle = mc:mock()
-- CONSTANTS



gItemsAlias = {
  thermoelectric = 'Thermoelectric Generator',
  capacitor = 'capacitor',
  ice = 'ice',
  blutonium = 'blutonium'
}
-- END CONSTANTS

-- MOCKED FUNCTIONS.

-- SETTINGS
gSize = 10
gStorage = peripheral.wrap('back')

-- gStorage.getInventorySize()
-- gStorage.getStackInSlot()
gItemsToStore = {}
table.insert(gItemsToStore, {startSlot = 1, endSlot = 4, item = gItemsAlias.thermoelectric})
table.insert(gItemsToStore, {startSlot = 5, endSlot = 8, item = gItemsAlias.blutonium})
table.insert(gItemsToStore, {startSlot = 9, endSlot = 12, item = gItemsAlias.ice})
table.insert(gItemsToStore, {startSlot = 13, endSlot = 16, item = gItemsAlias.capacitor})


-- END SETTINGS

-- INITIALIZERS


gCurrentPos = { -- standard cartesian. +x is east, +y is north, +z is upwards.
  x = 0, -- east or west
  y = 0, -- north or south
  z = 0 -- height
}
gCurrentOrientation = 0 -- quadrant rule, 0 is east
gNumericToWordOrientationMapping = {
  [0] = 'east',
  [1] = 'north',
  [2] = 'west',
  [3] = 'south',
}
gWordToNumericOrientationMapping = {}
for k,v in pairs(gNumericToWordOrientationMapping) do
  gWordToNumericOrientationMapping[v] = k
end

-- END INITIALIZERS

function turnTurtle (leftOrRight)
  if leftOrRight == 'left' then
    gCurrentOrientation = gCurrentOrientation + 1
    turtle.turnLeft()
  elseif leftOrRight == 'right' then
    gCurrentOrientation = gCurrentOrientation - 1
    turtle.turnRight()
  end

  gCurrentOrientation = normalizeOrientation(gCurrentOrientation)
end

function turnTurtleByNum (amount)
  local numOfTurns = math.abs(amount)
  for i=1,numOfTurns do
    if amount < 0 then
      turnTurtle('left')
    elseif amount > 0 then
      turnTurtle('right')
    end
  end
end

function normalizeOrientation (orientation)
  if orientation > 3 then
    -- find the distance to 1
    local distance = math.abs(orientation - 1)
    -- divide distance by 4, to see how many times it should be travelled.
    local timesLooped = math.floor(distance / 4)
    orientation = orientation - 4 * timesLooped
  elseif orientation < 0 then
    -- find the distance to 1.
    local distance = math.abs(orientation + 1)
    -- divide distance by 4, to see how many times it should be travelled.
    local timesLooped = math.ceil(distance / 4)
    orientation = orientation + 4 * timesLooped
  end
  return orientation
end

function convertOrientationToOrigin (orientation, offset)
  local newOrientation = orientation + offset
  local normalizedOrientation = normalizeOrientation(newOrientation)
  return normalizedOrientation
end

function turnsRequired (currentOrientation, finalOrientation) -- positive is Left, negative is Right
  -- see how many turns required for left, and see how many turns required for right.
  -- first, we set everything relative to the origin to ease the math.
  local originOffset = - currentOrientation + 1
  finalOrientation = convertOrientationToOrigin(finalOrientation, originOffset)
  -- next, we abuse trigo, and create an alias of final orientation
  local aliasFinalOrientation = finalOrientation - 4
  -- now, we check which one is shorter.
  local turnsLeft = finalOrientation -- there should be a currentOrientation term, but it's 0
  local turnsRight = aliasFinalOrientation -- there should be a currentOrientation term, but it's 0
  if turnsLeft <= math.abs(turnsRight) then
    return turnsLeft
  else
    return turnsRight
  end
end

function setNewPosXY (offsetAmount)
  local direction = gWordToNumericOrientationMapping[gCurrentOrientation]
  if direction == 'east' then
    gCurrentPos.x = gCurrentPos.x + offsetAmount
  elseif direction == 'north' then
    gCurrentPos.y = gCurrentPos.y + offsetAmount
  elseif direction == 'west' then
    gCurrentPos.x = gCurrentPos.x - offsetAmount
  elseif direction == 'south' then
    gCurrentPos.y = gCurrentPos.y - offsetAmount
  end
end

function setNewPosZ (offsetAmount)
  gCurrentPos.z = gCurrentPos.z + offsetAmount
end

function moveForward()
  if turtle.getFuelLevel() < 1 then
    return 'nofuel'
  end
  turtle.forward()
  setNewPosXY(1)
  return true
end

function moveBack ()
  if turtle.getFuelLevel() < 1 then
    return 'nofuel'
  end
  turtle.back()
  setNewPosXY(-1)
  return true
end

function moveUp ()
  if turtle.getFuelLevel() < 1 then
    return 'nofuel'
  end
  turtle.up()
  setNewPosZ(1)
  return true
end

function moveDown ()
  if turtle.getFuelLevel() < 1 then
    return 'nofuel'
  end
  turtle.down()
  setNewPosZ(-1)
  return true
end

function moveX (x)
  -- gotta change our orientation to face east first
  local turns = turnsRequired(gCurrentOrientation, 0)
  turnTurtleByNum(turns)
  for i=1,math.abs(x) do
    if x > 0 then
      moveForward()
    elseif x < 0 then
      moveBack()
    else
      break
    end
  end
end

function moveY (y)
  -- gotta change our orientation to face north first.
  local turns = turnsRequired(gCurrentOrientation, 1)
  turnTurtleByNum(turns)
  for i=1,math.abs(y) do
    if y > 0 then
      moveForward()
    elseif y < 0 then
      moveBack()
    else
      break
    end
  end
end

function moveZ (z)
  for i=1,math.abs(z) do
    if z > 0 then
      moveUp()
    elseif z < 0 then
      moveDown()
    else
      break
    end
  end
end

function deployItem(direction, item)
  if turtle.getFuelLevel() < 1 then
    return 'nofuel'
  end
  -- find item in inventory.
  local itemSlot = 0
  for i=1,16 do
    itemSlot = turtle.getItemDetail(i)
    if itemSlot.name == item then
      turtle.select(i)
      placeItem(direction)
      return true
    end
  end
  -- item isn't in turtle!? let's do this again after refilling!
  refillItemsAndReturn()
  return deployItem(direction, item)
end

function placeItem (direction)
  if direction == 'up' then
    turtle.placeUp()
  elseif direction == 'down' then
    turtle.placeDown()
  end
end

function refillItemsAndReturn()
  local jobList = {}
  -- remember this position, just in case
  local workHaltedPosition = gCurrentPos
  -- remember the orientation as well!
  local workHaltedOrientation = gCurrentOrientation
  -- move forward
  moveForward()
  -- remember this position too!
  local helperPosition = gCurrentPos
  -- let's raise ourselves to length height + 1
  table.insert(jobList,addJobMove({dx = 0, dy = 0, dz = gSize + 1}, {'dx', 'dy', 'dz'}))
  -- now, move to origin! Get x to be 0, get y to be 0
  -- get a jobMove.
  table.insert(jobList, addJobMoveAbs({x = 0, y = 0, z = 0}, {'dx', 'dy', 'dz'}))
  -- refill our stuff
  table.insert(jobList,addJobChangeOrientation('south'))
  table.insert(jobList,addJobRefillStackMany(gItemsToStore))
  -- and then, set our orientation to face north
  table.insert(jobList,addJobChangeOrientation('north'))
  -- and go back to our old place.
  -- start off by going to 11.
  table.insert(jobList, addJobMove({dx = 0, dy = 0, dz = 11}, {'dx', 'dy', 'dz'}))
  -- then go to helperPosition.
  table.insert(jobList,addJobMoveAbs(helperPosition, {'dx', 'dy', 'dz'}))
  -- then go to the workHaltedPosition
  table.insert(jobList,addJobMoveAbs(workHaltedPosition, {'dx', 'dy', 'dz'}))
  -- then change our orientation back.
  table.insert(jobList,addJobChangeOrientation(gNumericToWordOrientationMapping[workHaltedOrientation]))
  -- do the jobs.
  doAllJobs(jobList)
  -- WE'RE BACK!
end

-- http://stackoverflow.com/questions/2421695/first-character-uppercase-lua
function firstToUpper(str)
    return (str:gsub("^%l", string.upper))
end

job = {
  addJobMove = function(delta, order)
    return {
      name = 'jobMove',
      data = { delta = delta, order = order}
      -- order {'dz', 'dy', 'dx'}
      -- delta {dx = int, dy = int, dz = int}
    }
  end,

  doJobMovement = function(jobMove)
    for k,v in pairs(jobMove.data.order) do
      if v == 'dx' then
        moveX(jobMove.delta.dx)
      elseif v == 'dy' then
        moveY(jobMove.delta.dy)
      elseif v == 'dz' then
        moveZ(jobMove.delta.dx)
      end
    end
  end,

  addJobMoveAbs = function (coord, order)
    return {
      name = 'jobMoveAbs',
      data = {coord = coord, order = order}
      -- order {'dz', 'dy', 'dx'}
      -- cord {x = int, y = int, z = int}
    }
  end,

  doJobMovementAbs = function (jobMoveAbs)
    -- get current position and get dx, dy, dz.
    local delta = {
      dx = gCurrentPos.x - jobMoveAbs.coord.x,
      dy = gCurrentPos.y - jobMoveAbs.coord.y,
      dz = gCurrentPos.z - jobMoveAbs.coord.z
    }
    doJobMovement(addJobMove(delta, jobMoveAbs.order))
  end,

  addJobChangeOrientation = function(orientation)
    local jobChangeOrientation = {
      name = 'jobChangeOrientation',
      data = {orientation = orientation}
    }
    return jobChangeOrientation
  end,

  doJobChangeOrientation = function (jobChangeOrientation)
    local targetOrientation = gWordToNumericOrientationMapping[jobChangeOrientation.data.orientation]
    local turns = turnsRequired(gCurrentOrientation, targetOrientation)
    turnTurtleByNum(turns)
    return true
  end,

  addJobExtrusion = function(height, item)
    return {
      name = 'jobExtrusion',
      data = {height = height, item = item}
    }
  end,

  doJobExtrusion = function(jobExtrusion)
    -- let's check where we are. then reposition ourselves.
    local distanceToTop = math.abs(gCurrentPos.z - 1)
    local distanceToBottom = math.abs(gCurrentPos.z - (jobExtrusion.data.height - 1))
    local jobList = {}
    local reverseDirectionMulti = 1
    if gCurrentPos.z < 1 or gCurrentPos.z > (jobExtrusion.data.height - 1) then
      reverseDirectionMulti = -1
    end
    if distanceToBottom > distanceToTop then
      for i=1,distanceToTop do
        table.insert(jobList,job.addJobMove({dx = 0, dy = 0, dz = 1 * reverseDirectionMulti}, {'dx', 'dy', 'dz'}))
      end
      local placementDirection = 'up'
      local dz = -1
    elseif distanceToBottom <= distanceToTop then
      for i=1,distanceToBottom do
        table.insert(jobList,job.addJobMove({dx = 0, dy = 0, dz = -1 * reverseDirectionMulti}, {'dx', 'dy', 'dz'}))
      end
      local placementDirection = 'down'
      local dz = 1
    end
    -- now, we extrude.
    for i=1,jobExtrusion.data.height do
      table.insert(jobList,job.addJobMove({dx = 0, dy = 0, dz = dz}, {'dx', 'dy', 'dz'}))
      table.insert(jobList,job.addJobDeployItem(jobExtrusion.data.item, placementDirection))
    end
    doAllJobs(jobList)
  end,

  addJobDeployItem = function (item, direction)
    return {
      name = 'jobDeployItem',
      data = {item = item, direction = direction}
    }
  end,

  doJobDeployItem = function (jobDeployItem)
    deployItem(jobDeployItem.data.direction, jobDeployItem.data.item)
  end,

  addJobForOddRows = function(length)
    return {
      name = 'jobForOddRows',
      data = {length = length}
    }
  end,

  doJobForOddRows = function(jobForOddRows)
    -- we're starting at the bottom, and at the first tower, first block. ALWAYS.
    -- we need to know whether we're 1, 5, 9 or are we 3, 7, 11, etc.
    -- so let's find our nthOdd. if even, put blutonium first. if not, put ice first.
    local nthOdd = getNthOdd(gCurrentPos.x)
    local itemPeriod = {}
    if nthOdd % 2 then
      table.insert(itemPeriod,gItemsAlias.blutonium)
      table.insert(itemPeriod,gItemsAlias.thermoelectric)
      table.insert(itemPeriod,gItemsAlias.ice)
      table.insert(itemPeriod,gItemsAlias.thermoelectric)
    else
      table.insert(itemPeriod,gItemsAlias.ice)
      table.insert(itemPeriod,gItemsAlias.thermoelectric)
      table.insert(itemPeriod,gItemsAlias.blutonium)
      table.insert(itemPeriod,gItemsAlias.thermoelectric)
    end
    -- make our item order.
    local itemOrder = {}
    local i = 1
    while i <= jobForOddRows.data.length do
      for j=1,#itemPeriod do
        table.insert(itemOrder,itemPeriod[j])
        i = i + 1
        if i > jobForOddRows.data.length then
          break
        end
      end
      if i > jobForOddRows.data.length then
        break
      end
    end
    -- with these items, setup our extrusion jobs.
    local jobList = {}
    for k,v in pairs(itemOrder) do
      table.insert(jobList,addJobExtrusion(gSize, v))
      table.insert(jobList,addJobMoveForward())
    end
    table.insert(jobList,addJobMove({dx = 1, dy = 0, dz = 0}, {'dx', 'dy', 'dz'}))
    -- then face south.
    table.insert(jobList,addJobChangeOrientation('south'))
    -- and do all the jobs :)
    doAllJobs(jobList)
  end,

  addJobForEvenRows = function(length)
    return {
      name = 'jobForEvenRows',
      data = {length = length}
    }
  end,

  doJobForEvenRows = function (jobForEvenRows)
    -- we're starting at the bottom. ALWAYS.  Let's move forward
    -- we need to know whether we're 1, 5, 9 or are we 3, 7, 11, etc.
    -- so let's find our nthOdd. if even, put blutonium first. if not, put ice first.
    local itemPeriod = {
      'thermoelectric',
      'capacitor',
    }
    -- make our item order.
    local itemOrder = {}
    local i = 1
    while i <= jobForEvenRows.data.length do
      for j=1,#itemPeriod do
        table.insert(itemOrder,itemPeriod[j])
        i = i + 1
        if i > jobForEvenRows.data.length then
          break
        end
      end
      if i > jobForEvenRows.data.length then
        break
      end
    end
    -- with these items, setup our extrusion jobs.
    local jobList = {}
    for k,item in pairs(itemOrder) do
      table.insert(jobList,addJobExtrusion(gSize, item))
      table.insert(jobList,addJobMoveForward())
    end
    -- add jobs to prepare for the next row.
    table.insert(jobList,addJobMove({dx = 1, dy = 0, dz = 0}, {'dx', 'dy', 'dz'}))
    -- then face north.
    table.insert(jobList,addJobChangeOrientation('north'))
    -- and do all the jobs :)
    doAllJobs(jobList)
  end,

  addJobMoveForward = function ()
    return {
      name = 'jobMoveForward'
    }
  end,

  doJobMoveForward = function (jobMoveForward)
    moveForward()
  end,

  addJobMoveBack = function ()
    return {
      name = 'jobMoveBack'
    }
  end,

  doJobMoveBack = function (jobMoveBack)
    moveBack()
  end,

  addJobMoveUp = function ()
    return {
      name = 'jobMoveUp'
    }
  end,

  doJobMoveUp = function (jobMoveUp)
    moveDown()
  end,

  addJobMoveUp = function ()
    return {
      name = 'jobMoveUp'
    }
  end,

  doJobMoveUp = function (jobMoveUp)
    moveUp()
  end,

  addJobRefillStackMany = function(itemList)
    -- format
    -- itemList = {
    --   startSlot = 0,
    --   endSlot = 4,
    --   item = 'thermoelectric',
    -- }
    return {
      name = 'jobRefillStackMany',
      data = {itemList = itemList}
    }
  end,

  doJobRefillStackMany = function (jobRefillStackMany)
    local jobList = {}
    for k,v in pairs(jobRefillStackMany.data.itemList) do
      table.insert(jobList, job.addJobRefillStack(v.item, v.startSlot, v.endSlot))
    end
    doAllJobs(jobList)
  end,

  -- you must be facing a chest.
  addJobRefillStack = function(item, startSlot, endSlot)
    return {
      name = 'jobRefillStack',
      data = {item = item, startSlot = startSlot, endSlot = endSlot}
    }
  end,

  doJobRefillStack = function(jobRefillStack)
    local inventorySize = gStorage.getInventorySize()
    for k,item in pairs(jobRefillStack.data) do
      for i=item.startSlot,item.endSlot do
        for j=1,inventorySize do
          local itemInStorage = gStorage.getStackInSlot(j)
          if itemInStorage.display_name == item.item then
            gStorage.pushItemIntoSlot('back', j, 64, i)
          end
        end
      end
    end
  end,
}

doAllJobs = function(jobList)
  for k,jobVal in pairs(jobList) do
    local doJobFunc = 'do' .. firstToUpper(jobVal.name)
    job[doJobFunc](jobVal)
  end
end




function getNthOdd (oddNumber)
  -- nth odd number, 2(n-1) + 1 = v
  -- therfore, to solve for n, 2(n-1) = v - 1, (n-1) = (v-1)/2, n = (v-1)/2 + 1
  return (oddNumber + 1) / 2
end



function generateJobListForSize() -- squarish, must be in
  local jobList = {}
  -- start by grabbing items required for our tower.
  -- let's assume our chest is south of origin.
  table.insert(jobList, job.addJobChangeOrientation('south'))
  -- then pick up our stack of items.
  table.insert(jobList, job.addJobRefillStackMany(gItemsToStore))
  -- now, let's get to work. Move to 1, 1, 1 first. 1, 1, 1 is empty.
  -- why 1, 1, 1? because you need to place blocks below the turtle, or above it.
  table.insert(jobList, job.addJobMove({dx = 1, dy = 1, dz = 1}, {'dx', 'dy', 'dz'}))
  -- then face north.
  table.insert(jobList, job.addJobChangeOrientation('north'))

  -- let's queue up our jobs.
  for i=1,gSize do
    local isOdd = i % 2
    if isOdd then
      -- do the thing for odd rows.
      table.insert(jobList, job.addJobForOddRows(gSize))
    else
      -- do the thing for even rows.
      table.insert(jobList, job.addJobForEvenRows(gSize))
    end
  end
  return jobList
end

doAllJobs(generateJobListForSize())
