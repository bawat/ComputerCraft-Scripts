local scanner = peripheral.find("geoScanner")
local datastore = require("datastore")
if scanner ~= nil then
    print("Fuel: " .. scanner.getFuelLevel() .. " (-" .. scanner.cost(16) .. ")")
end
--Radius centered on the scanner
--Radius=1 returns the surrounding blocks
--Always returns itself

function elemsEqual (ele1, ele2)
    if ele1 == ele2 then return true end
    if ele1.name ~= ele2.name then return false end
    if ele1.x ~= ele2.x then return false end
    if ele1.y ~= ele2.y then return false end
    if ele1.z ~= ele2.z then return false end
    return true
end
function contains (t, value)
    for _, v in pairs(t) do
        if elemsEqual(v, value) then
            return true
        end
    end
    return false
end
function mergeTables (t1, t2)
    local retTable = {}
    for k,v in pairs(t2) do
        if not contains(retTable, v) then
            table.insert(retTable, v)
        end
    end
    for k,v in pairs(t1) do
        if not contains(retTable, v) then
            table.insert(retTable, v)
        end
    end
    return retTable
end
local function addTableToStore (survey)
    local store = datastore.get()
    print("Store Serialised " .. textutils.serialise(store))
    local oreLog = store["oreLog"] or {}
    print("Orelog length " .. #oreLog .. ". Survey Length " .. #survey)
    local mergedTables = mergeTables(oreLog, survey)
    store["oreLog"] = mergedTables
    print("New Orelog length " .. #store["oreLog"])
    datastore.set(store)
    print("Sanity check'd length " .. #(datastore.get()["oreLog"]))
end
function translateTable (table,dx,dy,dz)
    for i, ele in pairs(table) do
        ele.x = ele.x + dx
        ele.y = ele.y + dy
        ele.z = ele.z + dz
    end
end
local function removeOreFromStore(location)
    local store = datastore.get()
    local oreLog = store["oreLog"]
    for i = #oreLog,1,-1 do
        local ore = oreLog[i]
        if ore.x == location.x and ore.y == location.y and ore.z == location.z then
            table.remove(oreLog, i)
            break
        end
    end
    store["oreLog"] = oreLog
    datastore.set(store)
end
function hasClaimExpired(ore)
    return ore.claimTime == nil or ore.claimTime < os.time() - 2*60
end
local function findClosestUnclaimedOre(location)
    local mePos = vector.new(location.x,location.y,location.z)
    local closestOre = nil
    local store = datastore.get()
    local oreLog = store["oreLog"]
    for _, ore in ipairs(oreLog) do
        local orePos = vector.new(ore.x,ore.y,ore.z)
        if hasClaimExpired(ore) then
            if closestOre == nil or orePos:sub(mePos):length() < closestOre:sub(mePos):length() then
                closestOre = orePos
            end
        end
    end
    return closestOre
end
function filterScan(survey)
    local filteredOres = {}
    
    local store = datastore.get()
    local oreSet = {}
    for _, oreType in ipairs(store["wantedOres"]) do
        oreSet[oreType] = true
    end
    
    for  _, block in ipairs(survey) do
        if oreSet[block.name] then
            table.insert(filteredOres, {
                x = block.x,
                y = block.y,
                z = block.z
            })
        end
    end
    
    return filteredOres
end
local function performScan (radius)
    local swapper = require("hotswap")
    swapper.swapToGeoScanner()
    local scanner = peripheral.find("geoScanner")
    local survey = scanner.scan(radius)
    
    local modem = require("modemTools")
    local loc = modem.useGPS()
    survey = filterScan(survey)
    translateTable(survey, loc.x, loc.y, loc.z)
    return survey
end

function get2DScanLocation (index)
    local startX = 0
    local startY = 0
    local currConsecX = 0
    local currConsecY = 0
    local consecLimit = 1
    local dirFlipper = 1
        
    for i=1,index,1 do
        if currConsecX < consecLimit then
            startX = startX + dirFlipper
            currConsecX = currConsecX + 1
        elseif currConsecY < consecLimit then
            startY = startY + dirFlipper
            currConsecY = currConsecY + 1
        end
        if currConsecY == consecLimit then
            consecLimit = consecLimit + 1
            currConsecX = 0
            currConsecY = 0
            dirFlipper = dirFlipper * -1
        end
    end
    return vector.new(startX, 0, startY)
end
function verticalScanLocation (index, store)
    local startZ = store["scanStartLocation"].y
    local lowestZ = store["bedrockHeight"]
    local multiple = 1+math.floor(math.abs((startZ - lowestZ)/(1+2*store["scanRadius"])))
    
    local index2D = math.floor(index/multiple)
    local indexDepth = math.fmod(index, multiple)
    local loc2D = get2DScanLocation(index2D)

    return loc2D:add(vector.new(0, -indexDepth, 0))
end
function getVectorFromStorage (name, store)
    local vec = store[name]
    return vector.new(vec.x, vec.y, vec.z)
end
local function getScanLocation (index)
    local store = datastore.get()
    local unscaledLoc = verticalScanLocation(index, store)
    local startLoc = getVectorFromStorage("scanStartLocation", store)
    local scaledLoc = unscaledLoc:mul(store["scanRadius"]*2 + 1)
    local finalLoc = startLoc:add(scaledLoc)
    
    return finalLoc
end

return {addTableToStore = addTableToStore, getScanLocation = getScanLocation, removeOreFromStore = removeOreFromStore, findClosestUnclaimedOre = findClosestUnclaimedOre, performScan = performScan}
