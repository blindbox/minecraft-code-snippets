-- turtle.craft(number quantity)
-- turtle.forward()
-- turtle.back()
-- turtle.up()
-- turtle.down()
-- turtle.turnLeft()
-- turtle.turnRight()
-- turtle.select(number slotNum)
-- turtle.getSelectedSlot()
-- turtle.getItemCount([numberslotNum])
-- turtle.getItemSpace([numberslotNum])
-- turtle.getItemDetail([numberslotNum])
-- turtle.equipLeft()
-- turtle.equipRight()
-- turtle.attack()
-- turtle.attackUp()
-- turtle.attackDown()
-- turtle.dig()
-- turtle.digUp()
-- turtle.digDown()
-- turtle.place([string signText])
-- turtle.placeUp()
-- turtle.placeDown()
-- turtle.detect()
-- turtle.detectUp()
-- turtle.detectDown()
-- turtle.inspect()
-- turtle.inspectUp()
-- turtle.inspectDown()
-- turtle.compare()
-- turtle.compareUp()
-- turtle.compareDown()
-- turtle.compareTo(number slot)
-- turtle.drop([number count])
--
-- turtle.dropUp([number count])
--
-- turtle.dropDown([numbercount])
--
-- turtle.suck([number amount])
-- turtle.suckUp([numberamount])
-- turtle.suckDown([numberamount])
-- turtle.refuel([number quantity])
--
-- turtle.getFuelLevel()
--
-- turtle.getFuelLimit()
--
-- turtle.transferTo(number slot [,number quantity])

-- end ignore
-- uncomment these after programming
turtle = {}
peripheral = {}
-- end uncomment
-- CONSTANTS
gItemsAlias = {
  thermoelectric = 'Thermoelectric Generator',
  capacitor = 'capacitor',
  ice = 'ice',
  blutonium = 'blutonium'
}
-- END CONSTANTS

-- SETTINGS
gSize = 10
gStorage = peripheral.wrap('forward')
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
  numOfTurns = math.abs(amount)
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
    distance = math.abs(orientation - 1)
    -- divide distance by 4, to see how many times it should be travelled.
    timesLooped = math.floor(distance / 4)
    orientation = orientation - 4 * timesLooped
  elseif orientation < 0 then
    -- find the distance to 1.
    distance = math.abs(orientation + 1)
    -- divide distance by 4, to see how many times it should be travelled.
    timesLooped = math.ceil(distance / 4)
    orientation = orientation + 4 * timesLooped
  end
  return orientation
end

function convertOrientationToOrigin (orientation, offset)
  newOrientation = orientation + offset
  normalizedOrientation = normalizeOrientation(newOrientation)
  return normalizedOrientation
end

function turnsRequired (currentOrientation, finalOrientation) -- positive is Left, negative is Right
  -- see how many turns required for left, and see how many turns required for right.
  -- first, we set everything relative to the origin to ease the math.
  originOffset = - currentOrientation + 1
  finalOrientation = convertOrientationToOrigin(finalOrientation, originOffset)
  -- next, we abuse trigo, and create an alias of final orientation
  aliasFinalOrientation = finalOrientation - 4
  -- now, we check which one is shorter.
  turnsLeft = finalOrientation -- there should be a currentOrientation term, but it's 0
  turnsRight = aliasFinalOrientation -- there should be a currentOrientation term, but it's 0
  if turnsLeft <= math.abs(turnsRight) then
    return turnsLeft
  else
    return turnsRight
  end
end

function setNewPosXY (offsetAmount)
  direction = gWordToNumericOrientationMapping[gCurrentOrientation]
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
  turns = turnsRequired(gCurrentOrientation, 0)
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
  turns = turnsRequired(gCurrentOrientation, 1)
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
  jobList = {}
  -- remember this position, just in case
  workHaltedPosition = gCurrentPos
  -- remember the orientation as well!
  workHaltedOrientation = gCurrentOrientation
  -- move forward
  moveForward()
  -- remember this position too!
  helperPosition = gCurrentPos
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

function doAllJobs(jobList)
  for k,job in pairs(jobList) do
    doJobFunc = 'do' .. firstToUpper(job.name)
    _G[doJobFunc](job)
  end
end

function addJobMove(delta, order)
  return {
    name = 'jobMove',
    data = { delta = delta, order = order}
    -- order {'dz', 'dy', 'dx'}
    -- delta {dx = int, dy = int, dz = int}
  }
end

function doJobMovement(jobMove)
  for k,v in pairs(jobMove.data.order) do
    if v == 'dx' then
      moveX(jobMove.delta.dx)
    elseif v == 'dy' then
      moveY(jobMove.delta.dy)
    elseif v == 'dz' then
      moveZ(jobMove.delta.dx)
    end
  end
end

function addJobMoveAbs (coord, order)
  return {
    name = 'jobMoveAbs',
    data = {coord = coord, order = order}
    -- order {'dz', 'dy', 'dx'}
    -- cord {x = int, y = int, z = int}
  }
end

function doJobMovementAbs (jobMoveAbs)
  -- get current position and get dx, dy, dz.
  delta = {
    dx = gCurrentPos.x - jobMoveAbs.coord.x,
    dy = gCurrentPos.y - jobMoveAbs.coord.y,
    dz = gCurrentPos.z - jobMoveAbs.coord.z
  }
  doJobMovement(addJobMove(delta, jobMoveAbs.order))
end

function addJobChangeOrientation(orientation)
  jobChangeOrientation = {
    name = 'jobChangeOrientation',
    data = {orientation = orientation}
  }
  return jobChangeOrientation
end

function doJobChangeOrientation (jobChangeOrientation)
  targetOrientation = gWordToNumericOrientationMapping[jobChangeOrientation.data.orientation]
  turns = turnsRequired(gCurrentOrientation, targetOrientation)
  turnTurtleByNum(turns)
  return true
end

function addJobExtrusion(height, item)
  return {
    name = 'jobExtrusion',
    data = {height = height, item = item}
  }
end

function doJobExtrusion(jobExtrusion)
  -- let's check where we are. then reposition ourselves.
  distanceToTop = math.abs(gCurrentPos.z - 1)
  distanceToBottom = math.abs(gCurrentPos.z - (jobExtrusion.data.height - 1))
  jobList = {}
  reverseDirectionMulti = 1
  if gCurrentPos.z < 1 or gCurrentPos.z > (jobExtrusion.data.height - 1) then
    reverseDirectionMulti = -1
  end
  if distanceToBottom > distanceToTop then
    for i=1,distanceToTop do
      table.insert(jobList,addJobMove({dx = 0, dy = 0, dz = 1 * reverseDirectionMulti}, {'dx', 'dy', 'dz'}))
    end
    placementDirection = 'up'
    dz = -1
  elseif distanceToBottom <= distanceToTop then
    for i=1,distanceToBottom do
      table.insert(jobList,addJobMove({dx = 0, dy = 0, dz = -1 * reverseDirectionMulti}, {'dx', 'dy', 'dz'}))
    end
    placementDirection = 'down'
    dz = 1
  end
  -- now, we extrude.
  for i=1,jobExtrusion.data.height do
    table.insert(jobList,addJobMove({dx = 0, dy = 0, dz = dz}, {'dx', 'dy', 'dz'}))
    table.insert(jobList,addJobDeployItem(jobExtrusion.data.item, placementDirection))
  end
  doAllJobs(jobList)
end

function addJobDeployItem (item, direction)
  return {
    name = 'jobDeployItem',
    data = {item = item, direction = direction}
  }
end

function doJobDeployItem (jobDeployItem)
  deployItem(jobDeployItem.data.direction, jobDeployItem.data.item)
end



function getNthOdd (oddNumber)
  -- nth odd number, 2(n-1) + 1 = v
  -- therfore, to solve for n, 2(n-1) = v - 1, (n-1) = (v-1)/2, n = (v-1)/2 + 1
  return (oddNumber + 1) / 2
end

function addJobForOddRows(length)
  return {
    name = 'jobForOddRows',
    data = {length = length}
  }
end

function doJobForOddRows(jobForOddRows)
  -- we're starting at the bottom, and at the first tower, first block. ALWAYS.
  -- we need to know whether we're 1, 5, 9 or are we 3, 7, 11, etc.
  -- so let's find our nthOdd. if even, put blutonium first. if not, put ice first.
  nthOdd = getNthOdd(gCurrentPos.x)
  itemPeriod = {}
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
  itemOrder = {}
  i = 1
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
  jobList = {}
  for k,v in pairs(itemOrder) do
    table.insert(jobList,addJobExtrusion(gSize, v))
    table.insert(jobList,addJobMoveForward())
  end
  table.insert(jobList,addJobMove({dx = 1, dy = 0, dz = 0}, {'dx', 'dy', 'dz'}))
  -- then face south.
  table.insert(jobList,addJobChangeOrientation('south'))
  -- and do all the jobs :)
  doAllJobs(jobList)
end

function addJobForEvenRows(length)
  return {
    name = 'jobForEvenRows',
    data = {length = length}
  }
end

function doJobForEvenRows (jobForEvenRows)
  -- we're starting at the bottom. ALWAYS.  Let's move forward
  -- we need to know whether we're 1, 5, 9 or are we 3, 7, 11, etc.
  -- so let's find our nthOdd. if even, put blutonium first. if not, put ice first.
  itemPeriod = {
    'thermoelectric',
    'capacitor',
  }
  -- make our item order.
  itemOrder = {}
  i = 1
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
  jobList = {}
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
end

function addJobMoveForward ()
  return {
    name = 'jobMoveForward'
  }
end

function doJobMoveForward (jobMoveForward)
  moveForward()
end

function addJobMoveBack ()
  return {
    name = 'jobMoveBack'
  }
end

function doJobMoveBack (jobMoveBack)
  moveBack()
end

function addJobMoveUp ()
  return {
    name = 'jobMoveUp'
  }
end

function doJobMoveUp (jobMoveUp)
  moveDown()
end

function addJobMoveUp ()
  return {
    name = 'jobMoveUp'
  }
end

function doJobMoveUp (jobMoveUp)
  moveUp()
end

function addJobRefillStackMany(itemList)
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
end

function doJobRefillStackMany (jobRefillStackMany)
  jobList = {}
  for k,v in pairs(doJobRefillStackMany.data.itemList) do
    table.insert(jobList,addJobRefillStack(v.item, v.startSlot, v.endSlot))
  end
  doAllJobs(jobList)
end

-- you must be facing a chest.
function addJobRefillStack(item, startSlot, endSlot)
  return {
    name = 'jobRefillStack',
    data = {item = item, startSlot = startSlot, endSlot = endSlot}
  }
end

function doJobRefillStack(jobRefillStack)
  inventorySize = gStorage.getInventorySize()
  for k,item in pairs(jobRefillStack.data) do
    for i=item.startSlot,item.endSlot do
      for j=1,inventorySize do
        itemInStorage = gStorage.getStackInSlot(j)
        if itemInStorage.display_name == item.item then
          gStorage.pushItemIntoSlot('back', j, 64, i)
        end
      end
    end
  end
end

function generateJobListForSize() -- squarish, must be in
  jobList = {}
  -- start by grabbing items required for our tower.
  -- let's assume our chest is south of origin.
  table.insert(jobList, addJobChangeOrientation('south'))
  -- then pick up our stack of items.
  table.insert(jobList,addJobRefillStackMany(gItemsToStore))
  -- now, let's get to work. Move to 1, 1, 1 first. 1, 1, 1 is empty.
  -- why 1, 1, 1? because you need to place blocks below the turtle, or above it.
  table.insert(jobList, addJobMove({dx = 1, dy = 1, dz = 1}, {'dx', 'dy', 'dz'}))
  -- then face north.
  table.insert(jobList, addJobChangeOrientation('north'))

  -- let's queue up our jobs.
  for i=1,gSize do
    isOdd = i % 2
    if isOdd then
      -- do the thing for odd rows.
      table.insert(jobList, addJobForOddRows(gSize))
    else
      -- do the thing for even rows.
      table.insert(jobList, addJobForEvenRows(gSize))
    end
  end
  return jobList
end

doAllJobs(generateJobListForSize())
