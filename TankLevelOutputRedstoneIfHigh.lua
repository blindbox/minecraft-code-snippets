function checkTankLevelLoop (tank, redstoneSide)
  tankStats = tank.getTankInfo()
  capacity = tankStats[1].capacity
  amount = tankStats[1].contents.amount
  percentage = amount / capacity * 100
  if percentage < 90 then
    redstone.setOutput(redstoneSide, true)
  else
    redstone.setOutput(redstoneSide, false)
  end
end

tank = peripheral.wrap("back")

while true do
  checkTankLevelLoop(tank, "left")
  os.sleep(1)
end
