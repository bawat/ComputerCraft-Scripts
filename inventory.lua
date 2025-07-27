function isTool(name)
    return name == "minecraft:diamond_pickaxe" or name == "advancedperipherals:geo_scanner" or
        name == "computercraft:wireless_modem_advanced" or
        name == "minecraft:diamond_axe"
end

function isJunk(name)
    return name == "minecraft:cobbled_deepslate"
        or name == "minecraft:cobblestone"
        or name == "minecraft:andesite"
        or name == "minecraft:gravel"
        or name == "minecraft:diorite"
        or name == "minecraft:tuff"
        or name == "minecraft:granite"
end

local function takeDump()
    for i = 1, 16, 1 do
        turtle.select(i)
        local deets = turtle.getItemDetail()
        if deets and not isTool(deets.name) then
            turtle.dropDown()
        end
    end
end
local function takeWoodcuttingDump()
    for i = 1, 16, 1 do
        turtle.select(i)
        local deets = turtle.getItemDetail()

        if deets and not isTool(deets.name) and not string.find(deets.name:lower(), "sapling") then
            turtle.dropDown()
        end
    end
end
local function trashJunk()
    for i = 1, 16, 1 do
        turtle.select(i)
        local deets = turtle.getItemDetail()
        if deets and isJunk(deets.name) then
            turtle.dropDown()
        end
    end
end
local function countFreeSlots()
    local free = 0
    for i = 1, 16, 1 do
        local deets = turtle.getItemDetail(i)
        if deets == nil then
            free = free + 1
        end
    end
    return free
end
local function organiseInventory()
    local organized = false

    repeat
        organized = false
        for slot1 = 1, 15 do
            local item1 = turtle.getItemDetail(slot1)
            if item1 ~= nil then
                for slot2 = slot1 + 1, 16 do
                    local item2 = turtle.getItemDetail(slot2)
                    if item2 ~= nil and item1.name == item2.name then
                        turtle.select(slot2)
                        if turtle.transferTo(slot1) then
                            organized = true
                            break -- Start over to ensure we catch all merges
                        end
                    end
                end
                if organized then break end
            end
        end
    until not organized

    print("Inventory organized!")
end

return {
    takeDump = takeDump,
    takeWoodcuttingDump = takeWoodcuttingDump,
    trashJunk = trashJunk,
    countFreeSlots = countFreeSlots,
    organiseInventory =
        organiseInventory
}
