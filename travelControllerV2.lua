local swapper = require("hotswap")
local modem = require("modemTools")

function updateOrientation_turnLeft()
  --write("<-")
  turtle.northAngle = math.mod(turtle.northAngle + 270, 360)
end

function updateOrientation_turnRight()
  --write("->")
  turtle.northAngle = math.mod(turtle.northAngle + 90, 360)
end

function checkBlockSafe(name)
  if name == "forbidden_arcanus:stella_arcanum" then
    return false
  end
  if name == "computercraft:turtle_normal" then
    return false
  end
  if name == "computercraft:turtle_advanced" then
    return false
  end
  return true
end

function safeDig(inspectCmd, detectCmd, digCmd)
  local _, blockData = inspectCmd()
  if detectCmd() and checkBlockSafe(blockData.name) then
    swapper.swapToPickOrHatchet()
    digCmd()
  end
end

function initialiseInternalGPS()
  if turtle.isInitialised == "initing" then
    return
  end
  turtle.isInitialised = "initing"

  turtle.pos = vector.new(0, 0, 0)
  turtle.northAngle = 0
  --print("initing")
  local start = modem.useGPS()

  local vertMomentum = 1
  local movedVert = 0
  while turtle.detect() do
    for i = 1, 4, 1 do
      if not turtle.detect() then
        break
      end
      turtle.turnLeft()
    end
    if turtle.detect() then
      for i = 1, vertMomentum, 1 do
        if math.mod(vertMomentum, 2) == 0 then
          turtle.up()
          movedVert = movedVert + 1
        else
          turtle.down()
          movedVert = movedVert - 1
        end
      end
      vertMomentum = vertMomentum + 1
    end
  end
  turtle.forward()
  local fin = modem.useGPS()
  turtle.back()
  while movedVert ~= 0 do
    if movedVert > 0 then
      turtle.down()
      movedVert = movedVert - 1
    else
      turtle.up()
      movedVert = movedVert + 1
    end
  end

  -- North is negative Z
  -- East is positive X
  local dz = fin.z - start.z
  local dx = fin.x - start.x

  if dz == -1 then
    turtle.northAngle = 0
  elseif dz == 1 then
    turtle.northAngle = 180
  elseif dx == 1 then
    turtle.northAngle = 90
  else
    turtle.northAngle = 270
  end
  --print("Turtle ang is " .. turtle.northAngle .. " dz=" .. dz .. " dx=" .. dx)

  local fin2 = modem.useGPS()
  turtle.pos = vector.new(fin2.x, fin2.y, fin2.z)
  print("Turtle localised: " .. textutils.serialise(turtle.pos))
end

function orientAngle(desiredNorthAngle)
  initialiseInternalGPS()

  --print("Northang: " .. turtle.northAngle .. " Desired: " .. desiredNorthAngle)
  local transform = 180 - math.mod(desiredNorthAngle + 360, 360)
  local transformedNorthAngle = math.mod(turtle.northAngle + transform + 360, 360)

  if transformedNorthAngle > 180 then
    turtle.turnLeft()
    --write("Lefting")
    orientAngle(desiredNorthAngle)
  elseif transformedNorthAngle < 180 then
    turtle.turnRight()
    --write("Righting")
    orientAngle(desiredNorthAngle)
  end
  --write("Ending")
end

function isAt(x, y, z)
  local pos = turtle.pos
  if x ~= pos.x then return false end
  if y ~= pos.y then return false end
  if z ~= pos.z then return false end
  return true
end

function travel(gx, gy, gz, shouldDig)
  local fails = -1
  while not isAt(gx, gy, gz) do
    local pos = vector.new(turtle.pos.x, turtle.pos.y, turtle.pos.z)
    if gz ~= pos.z then
      if gz > pos.z then
        turtle.orientSouth()
      elseif gz < pos.z then
        turtle.orientNorth()
      end
      for i = 1, math.abs(gz - pos.z), 1 do
        if shouldDig then
          turtle.dig()
        end
        turtle.forward()
      end
    end

    local pos2 = vector.new(turtle.pos.x, turtle.pos.y, turtle.pos.z)
    if gx ~= pos2.x then
      if gx < pos2.x then
        turtle.orientWest()
      elseif gx > pos2.x then
        turtle.orientEast()
      end
      for i = 1, math.abs(gx - pos2.x), 1 do
        if shouldDig then
          turtle.dig()
        end
        turtle.forward()
      end
    end

    for i = 1, math.abs(gy - pos2.y), 1 do
      if gy > pos2.y then
        if shouldDig then
          turtle.digUp()
        end
        turtle.up()
      else
        if shouldDig then
          turtle.digDown()
        end

        turtle.down()
      end
    end
  end
  fails = fails + 1
  if fails > 5 then
    local rand = math.random(6)
    if rand == 1 then
      if shouldDig then
        turtle.digUp()
      end
      turtle.up()
    elseif rand == 2 then
      if shouldDig then
        turtle.digDown()
      end
      turtle.down()
    elseif rand == 3 then
      turtle.orientEast()
      if shouldDig then
        turtle.dig()
      end
      turtle.forward()
    elseif rand == 4 then
      turtle.orientWest()
      if shouldDig then
        turtle.dig()
      end
      turtle.forward()
    elseif rand == 5 then
      turtle.orientNorth()
      if shouldDig then
        turtle.dig()
      end
      turtle.forward()
    elseif rand == 6 then
      turtle.orientSouth()
      if shouldDig then
        turtle.dig()
      end
      turtle.forward()
    end
  end
end

function isFallingBlock(blockName)
  local fallable_blocks = {
    ["minecraft:sand"] = true,
    ["minecraft:red_sand"] = true,
    ["minecraft:gravel"] = true,
    ["minecraft:anvil"] = true,
    ["minecraft:chipped_anvil"] = true,
    ["minecraft:damaged_anvil"] = true,
    ["minecraft:dragon_egg"] = true,
    ["minecraft:concrete_powder"] = true,
    ["minecraft:white_concrete_powder"] = true,
    ["minecraft:orange_concrete_powder"] = true,
    ["minecraft:magenta_concrete_powder"] = true,
    ["minecraft:light_blue_concrete_powder"] = true,
    ["minecraft:yellow_concrete_powder"] = true,
    ["minecraft:lime_concrete_powder"] = true,
    ["minecraft:pink_concrete_powder"] = true,
    ["minecraft:gray_concrete_powder"] = true,
    ["minecraft:light_gray_concrete_powder"] = true,
    ["minecraft:cyan_concrete_powder"] = true,
    ["minecraft:purple_concrete_powder"] = true,
    ["minecraft:blue_concrete_powder"] = true,
    ["minecraft:brown_concrete_powder"] = true,
    ["minecraft:green_concrete_powder"] = true,
    ["minecraft:red_concrete_powder"] = true,
    ["minecraft:black_concrete_powder"] = true
  }

  return fallable_blocks[blockName] or false
end

--Overwrite default methods
function startup()
  if turtle.isPlusPlus == true then
    print("I'm already using 100% of my brain.")
    return
  end
  turtle.isPlusPlus = true
  print("Powering up my braiiiinn...")

  local originalTurnRight = turtle.turnRight
  turtle.turnRight = function()
    originalTurnRight()
    updateOrientation_turnRight()
  end

  local originalTurnLeft = turtle.turnLeft
  turtle.turnLeft = function()
    originalTurnLeft()
    updateOrientation_turnLeft()
  end

  local originalDig = turtle.dig
  turtle.dig = function()
    safeDig(turtle.inspect, turtle.detect, originalDig)
  end

  local originalDigUp = turtle.digUp
  turtle.digUp = function()
    safeDig(turtle.inspectUp, turtle.detectUp, originalDigUp)
  end

  local originalDigDown = turtle.digDown
  turtle.digDown = function()
    safeDig(turtle.inspectDown, turtle.detectDown, originalDigDown)
  end

  local originalForward = turtle.forward
  turtle.forward = function()
    initialiseInternalGPS()
    if not turtle.detect() then
      turtle.pos = turtle.pos:add(vector.new(
        math.cos(math.rad(turtle.northAngle - 90)),
        0,
        math.sin(math.rad(turtle.northAngle - 90))
      ))
      originalForward()
    else
      if isFallingBlock(select(2, turtle.inspect()).name) then
        turtle.dig()
      end
    end
  end

  local originalBack = turtle.back
  turtle.back = function()
    initialiseInternalGPS()
    turtle.pos = turtle.pos:add(vector.new(
      math.cos(math.rad(turtle.northAngle - 90 + 180)),
      0,
      math.sin(math.rad(turtle.northAngle - 90 + 180))
    ))
    originalBack()
  end

  local originalUp = turtle.up
  turtle.up = function()
    initialiseInternalGPS()
    if not turtle.detectUp() then
      turtle.pos = turtle.pos:add(vector.new(0, 1, 0))
      originalUp()
    else
      if isFallingBlock(select(2, turtle.inspectUp()).name) then
        turtle.digUp()
      end
    end
  end

  local originalDown = turtle.down
  turtle.down = function()
    initialiseInternalGPS()
    if not turtle.detectDown() then
      turtle.pos = turtle.pos:add(vector.new(0, -1, 0))
      originalDown()
    else
      if isFallingBlock(select(2, turtle.inspectDown()).name) then
        turtle.digDown()
      end
    end
  end

  turtle.orientNorth = function()
    orientAngle(0)
  end

  turtle.orientEast = function()
    orientAngle(90)
  end

  turtle.orientSouth = function()
    orientAngle(180)
  end

  turtle.orientWest = function()
    orientAngle(-90)
  end

  turtle.goTo = function(pos)
    travel(pos.x, pos.y, pos.z, false)
  end
  turtle.digTo = function(pos)
    travel(pos.x, pos.y, pos.z, true)
  end
  turtle.travelPath = function(path)
    for i = 1, #path do
      turtle.goTo(path[i])
    end
  end
  turtle.travelPathReversed = function(path)
    for i = #path, 1, -1 do
      turtle.goTo(path[i])
    end
  end
  turtle.digCube = function(pos1, pos2)
    turtle.goTo(pos1)
    print("Arrived at starting position")

    -- Calculate the bounds (ensure we handle negative ranges correctly)
    local minX = math.min(pos1.x, pos2.x)
    local maxX = math.max(pos1.x, pos2.x)
    local minY = math.min(pos1.y, pos2.y)
    local maxY = math.max(pos1.y, pos2.y)
    local minZ = math.min(pos1.z, pos2.z)
    local maxZ = math.max(pos1.z, pos2.z)

    -- Dig each position in the cube
    turtle.digTo(vector.new(minX, minY, minZ))
    while true do
      local reverseX = ((turtle.pos.z - minZ) % 2) * 2 - 1
      local reverseAll = ((turtle.pos.y - minY) % 2) * 2 - 1

      local nextXPos = turtle.pos:add(vector.new(-reverseX * -reverseAll, 0, 0))
      local nextZPos = turtle.pos:add(vector.new(0, 0, 1 * -reverseAll))
      local nextYPos = turtle.pos:add(vector.new(0, 1, 0))
      if nextXPos.x >= minX and nextXPos.x <= maxX then
        turtle.digTo(nextXPos)
      elseif nextZPos.z >= minZ and nextZPos.z <= maxZ then
        turtle.digTo(nextZPos)
      elseif nextYPos.y <= maxY then
        turtle.digTo(nextYPos)
      else
        break
      end
    end
    print("Escavation finished!")
  end

  turtle.placeBlockAt = function(pos1, blockName)
    turtle.goTo(pos1:add(vector.new(0, 1, 0)))
    swapper.swapToItem(blockName)
    turtle.placeDown()
  end

  --print("Orienting..")
  turtle.orientNorth()

  print("Unlocked 100%   B R A I N   P O W E R!")
end

--print("Ok robot...")
startup()
--print("Ok robot!")
