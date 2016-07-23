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

-- SETTINGS
gSize = 10
gStorage = peripheral.wrap('forward')
gItemsToStore = {}
table.insert(gItemsToStore, {startSlot = 0, endSlot = 3, item = 'thermoelectric'})
table.insert(gItemsToStore, {startSlot = 4, endSlot = 7, item = 'blutonium'})
table.insert(gItemsToStore, {startSlot = 8, endSlot = 11, item = 'ice'})
table.insert(gItemsToStore, {startSlot = 12, endSlot = 15, item = 'capacitor'})

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

function setOrientation (orientation)
  gCurrentOrientation = gWordToNumericOrientationMapping[orientation]
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

function addJobExtrudePillar(height, item, direction)

end

function doJobExtrudePillar(jobExtrudePillar)
  -- check if we have enough item for given height.
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
  table.insert(jobList,addJobMovement({dx = 0, dy = 0, dz = gSize + 1}, {'dx', 'dy', 'dz'}))
  -- now, move to origin! Get x to be 0, get y to be 0
  -- get a jobMovement.
  table.insert(jobList, addJobMovementAbs({x = 0, y = 0, z = 0}, {'dx', 'dy', 'dz'}))
  -- refill our stuff
  table.insert(jobList,addJobChangeOrientation('south'))
  table.insert(jobList,addJobRefillStackMany(gItemsToStore))
  -- and then, set our orientation to face north
  table.insert(jobList,addJobChangeOrientation('north'))
  -- and go back to our old place.
  -- start off by going to 11.
  table.insert(jobList, addJobMovement({dx = 0, dy = 0, dz = 11}, {'dx', 'dy', 'dz'}))
  -- then go to helperPosition.
  table.insert(jobList,addJobMovementAbs(helperPosition, {'dx', 'dy', 'dz'}))
  -- then go to the workHaltedPosition
  table.insert(jobList,addJobMovementAbs(workHaltedPosition, {'dx', 'dy', 'dz'}))
  -- then change our orientation back.
  table.insert(jobList,addJobChangeOrientation(gNumericToWordOrientationMapping[workHaltedOrientation]))
  -- do the jobs.
  doAllJobs(jobList)
  -- WE'RE BACK!
end

function getStack(chest, chestLocation)

end

function goBackToStart()

end

function getBackToWork(secondLastPos, LastPos, orientation)

end

function isLocationAmbiguous()

end

function doAllJobs(jobList)

end

function doJob(jobEntry)

end

function addJobMovement(delta, order)
  return {
    name = 'jobMovement',
    data = { delta = delta, order = order}
    -- order {'dz', 'dy', 'dx'}
    -- delta {dx = int, dy = int, dz = int}
  }
end

function doJobMovement(jobMovement)
  for k,v in pairs(jobMovement.data.order) do
    if v == 'dx' then
      moveX(jobMovement.delta.dx)
    elseif v == 'dy' then
      moveY(jobMovement.delta.dy)
    elseif v == 'dz' then
      moveZ(jobMovement.delta.dx)
    end
  end
end

function addJobMovementAbs (coord, order)
  return {
    name = 'jobMovementAbs',
    data = {coord = coord, order = order}
    -- order {'dz', 'dy', 'dx'}
    -- cord {x = int, y = int, z = int}
  }
end

function doJobMovementAbs (jobMovementAbs)
  -- get current position and get dx, dy, dz.
  delta = {
    dx = gCurrentPos.x - jobMovementAbs.coord.x,
    dy = gCurrentPos.y - jobMovementAbs.coord.y,
    dz = gCurrentPos.z - jobMovementAbs.coord.z
  }
  doJobMovement(addJobMovement(delta, jobMovementAbs.order))
end

function addJobTurn(direction)

end

function doJobTurn (jobTurn)
  -- body...
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
  -- let's check where we are.
  extrudeDirection = 'down'
  dz = -1
  if gCurrentPos.z == 0 then
    extrudeDirection = 'up'
    dz = 1
  end
  jobList = {}
  -- now, we extrude.
  for i=1,jobExtrusion.data.height do
    table.insert(jobList,addJobMovement({dx = 0, dy = 0, dz = dz}, {'dx', 'dy', 'dz'}))
    table.insert(jobList,addJobDeployItem(jobExtrusion.data.item, extrudeDirection))
  end
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

function addJobForOddRows(length)
  return {
    name = 'jobForOddRows',
    data = {length = length}
  }
end

function getNthOdd (oddNumber)
  -- nth odd number, 2(n-1) + 1 = v
  -- therfore, to solve for n, 2(n-1) = v - 1, (n-1) = (v-1)/2, n = (v-1)/2 + 1
  return (oddNumber + 1) / 2
end

function doJobForOddRows(jobForOddRows)
  -- we're starting at the bottom. ALWAYS.  Let's move forward
  moveForward()
  -- we need to know whether we're 1, 5, 9 or are we 3, 7, 11, etc.
  -- so let's find our nthOdd. if even, put blutonium first. if not, put ice first.
  nthOdd = getNthOdd(gCurrentPos.x)
  itemPeriod = {}
  if nthOdd % 2 then
    itemPeriod = {
      'blutonium',
      'thermoelectric',
      'ice',
      'thermoelectric'
    }
  else
    itemPeriod = {
      'ice',
      'thermoelectric',
      'blutonium',
      'thermoelectric'
    }
  end
  -- make our item order.
  itemOrder = {}
  i = 1
  while i <= jobForOddRows.data.length do
    for j=1,4 do
      table.insert(itemOrder,itemPeriod[j])
      i = i + 1
      if i > jobForOddRows.data.length then
        break
      end
    end
  end
  -- with these items, setup our extrusion jobs.
  jobList = {}
  for k,v in pairs(itemOrder) do
    table.insert(jobList,addJobExtrusion(gSize, v))
    table.insert(jobList,addJobMovementForward())
  end
  -- add jobs to prepare for the next row.
  dz = 0;
  if gCurrentPos.z ~= 0 then
    dz = -10
  end
  table.insert(jobList,addJobMovement({dx = 1, dy = 0, dz = dz}, {'dx', 'dy', 'dz'}))
  -- then face south.
  table.insert(jobList,addJobChangeOrientation('south'))
  -- and do all the jobs :)
  doAllJobs(jobList)
end

function addJobForEvenRows(length)

end

function doJobForEvenRows (jobForEvenRows)
  -- body...
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
  -- finish me up.
end

function generateJobListForSize(length) -- squarish, must be in
  jobList = {}
  -- start by grabbing items required for our tower.
  -- let's assume our chest is south of origin.
  table.insert(jobList, addJobChangeOrientation('south'))
  -- then pick up our stack of items.
  table.insert(jobList,addJobRefillStackMany(gItemsToStore))
  -- now, let's get to work. Move to 1, 1, 0 first. 1, 1, 0 is empty.
  table.insert(jobList, addJobMovement({dx = 1, dy = 1, dz = 0}, {'dx', 'dy', 'dz'}))
  -- then face north.
  table.insert(jobList, addJobChangeOrientation('north'))

  -- let's queue up our jobs.
  for i=1,length do
    isOdd = i % 2
    if isOdd then
      -- do the thing for odd rows.
      table.insert(jobList, addJobForOddRows(length))
    else
      -- do the thing for even rows.
      table.insert(jobList, addJobForEvenRows(length))
    end
  end
end
