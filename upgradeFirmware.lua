function transferFiles ()
    local files = fs.list("disk/")
    for i = 1, #files do
        local filename = files[i]
        if filename ~= "upgradeFirmware.lua" and not fs.isDir("disk/" ..  filename) then
            if fs.exists("/" .. filename) then
                fs.delete("/" .. filename)
            end
            fs.copy("disk/" .. filename, "/" .. filename)
            print("Copied: " .. filename)
        end
    end
end
transferFiles()
