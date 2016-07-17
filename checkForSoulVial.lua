function checkForSoulVial (autoAct, autoActPos, redstoneSide)
  firstSlot = autoAct.getStackInSlot(1)
  if firstSlot ~= nil then
    redstone.setOutput(redstoneSide, true)
    redstone.setOutput(autoActPos, true)
  else
    redstone.setOutput(redstoneSide, false)
    redstone.setOutput(autoActPos, false)
  end
end

autoActPos = "bottom"
autoAct = peripheral.wrap(autoActPos)

while true do
  checkForSoulVial(autoAct, autoActPos, "back")
  os.sleep(1)
end
