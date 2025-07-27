local fileName = "depth.dat"
local function set(data)
  local file = fs.open(fileName, "w")
  file.write(textutils.serialize(data))
  file.close()
end
local function get()
  if not fs.exists(fileName) then
    init()
  end
  local file = fs.open(fileName, "r")
  local content = file.readAll()
  file.close()
  return textutils.unserialise(content)
end
function init()
  print("Initialising database...")
  local tmp = {}
  tmp["depth"] = 0
  set(tmp)
  print("done!")
end

return { get = get, set = set }
