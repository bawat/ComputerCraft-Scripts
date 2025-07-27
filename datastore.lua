local fileName = "database.dat"
local function set(data)
    local file = fs.open(fileName,"w")
    file.write(textutils.serialize(data))
    file.close()
end
local function get()
    if not fs.exists(fileName) then
        init()
    end
    local file = fs.open(fileName,"r")
    local content = file.readAll()
    file.close()
    return textutils.unserialise(content) 
end
function init()
    print("Initialising database...")
    local tmp = {}
    tmp["bedrockHeight"] = -60
    tmp["scanRadius"] = 16 --33x33x33 cube
    tmp["scanIndex"] = 0
    tmp["refuelLocation"] = vector.new(1698, 16, -7781)
    tmp["scanStartLocation"] = tmp["refuelLocation"]:add(vector.new(0,-16,0))
    tmp["wantedOres"] = {"minecraft:iron_ore","minecraft:deepslate_iron_ore","minecraft:diamond_ore","minecraft:deepslate_diamond_ore","minecraft:redstone_ore","minecraft:deepslate_redstone_ore","minecraft:lapis_ore","mineccraft:deepslate_lapis_ore"}
    tmp["oreLog"] = {}
    set(tmp)
    print("done!")
end

return {get = get, set = set}
