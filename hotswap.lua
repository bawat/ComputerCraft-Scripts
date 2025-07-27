local function findInventoryItem(itemName)
    for i = 1, 16, 1 do
        local info = turtle.getItemDetail(i)
        if info ~= nil and info.name == itemName then
            return i
        end
    end
    return -1;
end
local function swapToItem(itemName)
    local slot = findInventoryItem(itemName)
    if slot == -1 then
        return
    end
    turtle.select(slot)
    turtle.equipLeft()
end
local function swapToPick()
    swapToItem("minecraft:diamond_pickaxe")
end
local function swapToHatchet()
    swapToItem("minecraft:diamond_axe")
end
local function swapToPickOrHatchet()
    local slot = findInventoryItem("minecraft:diamond_pickaxe")
    if slot == -1 then
        swapToHatchet()
    else
        swapToPick()
    end
end
local function swapToModem()
    if turtle then
        swapToItem("computercraft:wireless_modem_advanced")
    end
    peripheral.find("modem", rednet.open)
end
local function swapToGeoScanner()
    swapToItem("advancedperipherals:geo_scanner")
end
local function swapToPrev()
    turtle.equipLeft()
end

return {
    swapToPrev = swapToPrev,
    swapToModem = swapToModem,
    swapToPick = swapToPick,
    swapToHatchet = swapToHatchet,
    swapToGeoScanner =
        swapToGeoScanner,
    swapToItem = swapToItem,
    findInventoryItem = findInventoryItem,
    swapToPickOrHatchet = swapToPickOrHatchet
}
