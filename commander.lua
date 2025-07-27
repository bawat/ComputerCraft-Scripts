local datastore = require("datastore")
local travelController = require("travelController")
local serverScanController = require("geoscan")
local refuelController = require("refuel")
local modem = require("modemTools")
local inventory = require("inventory")

local TASK_SCAN = "scan"
local TASK_REFUEL = "refuel"
local TASK_HUNT = "hunt"
local TASK_UPGRADE = "upgrade"
local TASK_WORK_START = "readyForWork"
local TASK_DUMP = "takeADump"

local STATE_COMPLETE = "Completed"

function networking (slave)
    if turtle then
        print("Beep boop! Awaiting commands from Mum.")
    end
    while true do
        if slave then
            local id, req = modem.receive(5)
            
            if id == nil or req == nil then
                --Self care tasks
                if inventory.countFreeSlots() < 8 then
                    inventory.trashJunk()
                    inventory.organiseInventory()
                    if inventory.countFreeSlots() < 8 then
                        modem.msgMum({task = TASK_DUMP})
                    end
                elseif turtle.getFuelLevel() < turtle.getFuelLimit() * 0.75 then
                    modem.msgMum({task = TASK_REFUEL})
                else
                    modem.msgMum({task = TASK_WORK_START})
                end
            elseif req.isOrderFromConsole then
                modem.msgMum({task=req.task, loc=modem.useGPS()})
            elseif req.task == TASK_DUMP then
                local loc = req.loc
                travelController.travel(loc.x,loc.y,loc.z)
                travelController.orientNorth()
                inventory.trashJunk()
                for i=0,8,1 do
                    turtle.up()
                end
                turtle.back()
                inventory.takeDump()
                turtle.up()
                turtle.forward()
                turtle.turnLeft()
                turtle.forward()
                for i=0,8,1 do
                    turtle.down()
                end            
            elseif req.task == TASK_REFUEL then
                local loc = req.loc
                travelController.travel(loc.x,loc.y,loc.z)
                travelController.orientNorth()
                inventory.trashJunk()
                for i=0,8,1 do
                    turtle.up()
                end
                turtle.turnRight() 
                turtle.forward()
                refuelController.refuel()
                turtle.up()
                turtle.back()
                turtle.back()
                for i=0,8,1 do
                    turtle.down()
                end
            elseif req.task == TASK_UPGRADE then    
                local loc = req.loc
                travelController.travel(loc.x,loc.y,loc.z)
                travelController.orientNorth()
                for i=0,8,1 do
                    turtle.up()
                end
                turtle.turnRight()
                turtle.forward()
                turtle.turnRight()
                shell.run("disk/upgradeFirmware.lua")
                turtle.turnLeft()
                turtle.up()
                turtle.back()
                turtle.back()
                for i=0,8,1 do
                    turtle.down()
                end
                shell.run(shell.getRunningProgram())
                return
            elseif req.task == TASK_HUNT then
                local loc = req.loc
                travelController.travel(loc.x,loc.y,loc.z)
                modem.msgMum({task = TASK_HUNT, state = STATE_COMPLETE, loc = loc})
            elseif req.task == TASK_SCAN then
                local loc = req.loc
                travelController.travel(loc.x,loc.y,loc.z)
                local survey = serverScanController.performScan(16)
                print("Survey complete. Sending data to Mum...")
                modem.msgMum({task = TASK_SCAN, state = STATE_COMPLETE, data = survey})
            end
        else
            local id, req = modem.receive()
            print("Checking tasks.." .. textutils.serialise(req.task))
            local store = datastore.get()
            if req.task == TASK_REFUEL then
                modem.send(id, {task = TASK_REFUEL, loc = store["refuelLocation"]})
            elseif req.task == TASK_UPGRADE then
                modem.send(id, {task = TASK_UPGRADE, loc = store["refuelLocation"]})
            elseif req.task == TASK_DUMP then
                modem.send(id, {task = TASK_DUMP, loc = store["refuelLocation"]})
            elseif req.task == TASK_HUNT then
                if req.state == STATE_COMPLETE then
                    serverScanController.removeOreFromStore(req.loc)
                    print("Hunt task completed!")
                else
                    print("Hunting " .. #store["oreLog"] .. " ores around: " .. textutils.serialise(req.loc))
                    local closest = serverScanController.findClosestUnclaimedOre(req.loc)
                    if closest ~= nil then
                        print("New target: " .. textutils.serialise(closest))
                        modem.send(id, {task = TASK_HUNT, loc = closest})
                    else
                        print("Not more ores in area!!")
                    end
                end
            elseif req.task == TASK_SCAN then
                if req.state == STATE_COMPLETE then
                    print("Scan task complete. Data length is " .. #(req.data))
                
                    serverScanController.addTableToStore(req.data)
                    
                else
                    local loc = serverScanController.getScanLocation(store["scanIndex"])
                    store["scanIndex"] = store["scanIndex"] + 1
                    datastore.set(store)
                    print("Given scan work to " .. id .. ". Explore " .. textutils.serialise(loc) .. ". Scan index has now been increased to " .. store["scanIndex"] .. ".")
                    modem.send(id, {task=TASK_SCAN, loc=loc})
                end
            elseif req.task == TASK_WORK_START then
                print("Finding you a job...")
                local packet = {task=TASK_HUNT, isOrderFromConsole=true}
                print("Orelog count is " .. #store["oreLog"])
                if #store["oreLog"] == 0 then
                    packet.task = TASK_SCAN
                end
                modem.send(id, packet)
            end        
        end
    end
end
networking(turtle)
