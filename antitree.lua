shell.run("travelControllerV2.lua")
local swapper = require("hotswap")
local inventoryManager = require("inventory")

local location_TreeWaiting = vector.new(1687, 92, -7752)
local location_Waypoint1 = location_TreeWaiting:add(vector.new(-3, 0, 0))
local location_Waypoint2 = location_Waypoint1:add(vector.new(0, 0, -30))
local location_Waypoint3 = location_Waypoint2:add(vector.new(0, -30, 0))
local location_Waypoint4 = location_Waypoint3:add(vector.new(0, 0, 7))
local location_RefuelDropoff = vector.new(1683, 39, -7768)
local location_RefuelPickup = vector.new(1681, 39, -7768)

local sapplingName = "ars_elemental:yellow_archwood_sapling"

turtle.goTo(location_TreeWaiting)
inventoryManager.takeWoodcuttingDump()

while true do
    if turtle.getFuelLevel() < turtle.getFuelLimit() - 1000 then
        turtle.goTo(location_Waypoint1)
        turtle.goTo(location_Waypoint2)
        turtle.goTo(location_Waypoint3)
        turtle.goTo(location_Waypoint4)
        turtle.goTo(location_RefuelDropoff)
        inventoryManager.takeWoodcuttingDump()
        while turtle.getFuelLevel() < turtle.getFuelLimit() - 1000 do
            turtle.goTo(location_RefuelPickup)
            turtle.suckDown()
            local bucketID = swapper.findInventoryItem("minecraft:lava_bucket")
            if bucketID ~= -1 then
                turtle.select(bucketID)
                turtle.refuel()
                turtle.goTo(location_RefuelDropoff)
                turtle.dropDown()
            end
        end
        turtle.goTo(location_Waypoint4)
        turtle.goTo(location_Waypoint3)
        turtle.goTo(location_Waypoint2)
        turtle.goTo(location_Waypoint1)
        turtle.goTo(location_TreeWaiting)
    end

    local blocked, topBlock = turtle.inspectUp()
    if blocked then
        turtle.digUp()
        local loc1 = vector.new(1682, 93, -7747)
        local loc2 = loc1:add(vector.new(11, 0, -11))
        loc2.y = 107

        turtle.digCube(loc1, loc2)
        turtle.goTo(location_TreeWaiting)
        turtle.orientNorth()
        turtle.up()

        local sappling = swapper.findInventoryItem(sapplingName)
        if sappling ~= -1 then
            turtle.select(sappling)
            turtle.place()
        end
        turtle.goTo(location_TreeWaiting)
        inventoryManager.takeWoodcuttingDump()
    end
end
