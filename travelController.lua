local swapper = require("hotswap")
local modem = require("modemTools")
function checkBlockSafe (name)
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
function safeDig (inspectCmd, detectCmd, digCmd)
    local _, blockData = inspectCmd()
    if detectCmd() and checkBlockSafe(blockData.name) then
        swapper.swapToPick()
        digCmd()
    end
end
function sDig ()
    safeDig(turtle.inspect, turtle.detect, turtle.dig)
end
function sDigUp ()
    safeDig(turtle.inspectUp, turtle.detectUp, turtle.digUp)
end
function sDigDown ()
    safeDig(turtle.inspectDown, turtle.detectDown, turtle.digDown)
end

local function orientNorth ()
    local start = modem.useGPS()
    
    for i=1,4,1 do
        if not turtle.detect() then
            break
        end
        turtle.turnLeft()
    end
    sDig()
    turtle.forward()
    local fin = modem.useGPS()
    turtle.back()
    if fin.z - start.z == -1 then
        return
    end
    if fin.z - start.z == 1 then
        turtle.turnLeft()
        turtle.turnLeft()
        return
    end
    turtle.turnLeft()
    
    sDig()
    turtle.forward()
    local fin2 = modem.useGPS()
    turtle.back()
    if fin2.z - fin.z == -1 then
        return
    end
    if fin2.z - fin.z == 1 then
        turtle.turnLeft()
        turtle.turnLeft()
        return
    end
end
function isAt(x, y, z)
    local pos = modem.useGPS()
    if x ~= pos.x then return false end
    if y ~= pos.y then return false end
    if z ~= pos.z then return false end
    return true
end
local function travel (gx, gy, gz)
    while not isAt(gx, gy, gz) do
    orientNorth()
    local pos = modem.useGPS()
    if gz > pos.z then
        turtle.turnLeft()
        turtle.turnLeft()
    end
    for i=1,math.abs(gz-pos.z),1 do
        sDig()
        turtle.forward()
    end
    orientNorth()
    turtle.turnRight()
    local pos2 = modem.useGPS()
    if gx < pos2.x then
        turtle.turnRight()
        turtle.turnRight()
    end
    for i=1,math.abs(gx-pos2.x),1 do
        sDig()
        turtle.forward()
    end
    
    for i=1,math.abs(gy-pos2.y),1 do
        if gy > pos2.y then
            sDigUp()
            turtle.up()
        else
            sDigDown()
            turtle.down()
        end
    end
    end
end
return {orientNorth = orientNorth, travel = travel}
