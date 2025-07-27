local hotswapper = require("hotswap")

local function refuel ()
    while turtle.getFuelLevel() < turtle.getFuelLimit() do
        turtle.suckDown()
        local bucketID = hotswapper.findInventoryItem("minecraft:lava_bucket")
        if bucketID ~= -1 then
            turtle.select(bucketID)
            turtle.refuel()
            turtle.drop()
        end
        print("Fuel: " .. turtle.getFuelLevel() .. "/" .. turtle.getFuelLimit())
    end
    print("Fully fueled!")
end

return {refuel = refuel}
