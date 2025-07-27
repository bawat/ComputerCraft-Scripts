local swapper = require("hotswap")
local function msgMum (message)
    swapper.swapToModem()
    rednet.send(6,message)
end
local function receive(timeoutSeconds)
    swapper.swapToModem()
    if timeoutSeconds then
        local senderID, message = rednet.receive(timeoutSeconds)
        return senderID, message
    else
        local senderID, message = rednet.receive()
        return senderID, message
    end
end
local function send(id, message)
    swapper.swapToModem()
    rednet.send(id, message)
end
local function useGPS()
    swapper.swapToModem()
    local x,y,z = gps.locate()
    return vector.new(x,y,z)
end
return {useGPS=useGPS, msgMum=msgMum, receive=receive, send=send}
