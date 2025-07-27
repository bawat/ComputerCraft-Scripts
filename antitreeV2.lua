shell.run("travelControllerV2.lua")
local swapper = require("hotswap")
local inventoryManager = require("inventory")



local name_Sappling = "biomeswevegone:witch_hazel_sapling"

local cube_Tree = {
    pos1 = vector.new(1694, 117, -7761),
    pos2 = vector.new(1694, 117, -7761):add(vector.new(8, 141 - 117, -8))
}

local location_TreeWaiting = vector.new(1698, 117, -7763)
local function_WaitingObserveFunction = turtle.inspect
local location_RefuelDropoff = vector.new(1683, 39, -7768)
local location_RefuelPickup = vector.new(1681, 39, -7768)
local location_PlaceSapplingAt = vector.new(1698, 117, -7765)

local location_Waypoint1 = location_TreeWaiting:add(vector.new(-10, 0, 0))
local location_Waypoint2 = location_Waypoint1:add(vector.new(0, 0, -15))
local location_Waypoint3 = location_Waypoint2:add(vector.new(0, -50, 0))
local location_Waypoint4 = location_Waypoint3:add(vector.new(0, 0, 7))
local path_ToDepot = {
    location_Waypoint1,
    location_Waypoint2,
    location_Waypoint3,
    location_Waypoint4
}

function workAsTreeCutter(cube_Tree, path_ToDepot, name_Sappling, location_PlaceSapplingAt, location_Waiting,
                          function_WaitingObserveFunction,
                          location_FuelPickup,
                          location_FuelDropoff)
    turtle.goTo(location_Waiting)
    inventoryManager.takeWoodcuttingDump()

    while true do
        if turtle.getFuelLevel() < turtle.getFuelLimit() - 1000 then
            turtle.travelPath(path_ToDepot)
            turtle.goTo(location_FuelDropoff)
            inventoryManager.takeWoodcuttingDump()
            while turtle.getFuelLevel() < turtle.getFuelLimit() - 1000 do
                turtle.goTo(location_FuelPickup)
                turtle.suckDown()
                local bucketID = swapper.findInventoryItem("minecraft:lava_bucket")
                if bucketID ~= -1 then
                    turtle.select(bucketID)
                    turtle.refuel()
                    turtle.goTo(location_FuelDropoff)
                    turtle.dropDown()
                end
            end
            turtle.travelPathReversed(path_ToDepot)
            turtle.goTo(location_Waiting)
        end

        turtle.orientNorth()
        local blocked, topBlock = function_WaitingObserveFunction()
        if blocked then
            turtle.digCube(cube_Tree.pos1, cube_Tree.pos2)
            turtle.goTo(location_Waiting)
            turtle.placeBlockAt(location_PlaceSapplingAt, name_Sappling)

            turtle.goTo(location_Waiting)
            inventoryManager.takeWoodcuttingDump()
        end
    end
end

workAsTreeCutter(cube_Tree, path_ToDepot, name_Sappling, location_PlaceSapplingAt, location_TreeWaiting,
    function_WaitingObserveFunction,
    location_RefuelPickup,
    location_RefuelDropoff)
