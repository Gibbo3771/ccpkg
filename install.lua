local params = {...}
local workingDir = "/.ccpkg"

local function updatePath()
    local paths = {
        package.path,
        "/.ccpgk/?.lua",
        "/.ccpgk/?"
    }
    package.path = table.concat(paths, ";")
    shell.setPath(shell.path()..":".."/.ccpkg/bin")
end

local function downloadDependencies()
    print("Downloading dependencies...")
    local deps = {
        "https://raw.githubusercontent.com/MCJack123/CC-Archive/master/LibDeflate.lua",
        "https://raw.githubusercontent.com/MCJack123/CC-Archive/master/tar.lua",
        "https://raw.githubusercontent.com/Gibbo3771/ccpkg/main/ccpkg.lua"
    }
    for i, v in ipairs(deps) do
        local filename = v:match("^.+/(.+)$")
        print("Downloading "..filename.." from "..v)
        local h, err, res = http.get(v)
        if(err) then
            print("Error downloading dependency '"..filename.."' from "..v)
            print(err)
            print(res.getResponseCode())
            error()
        end
        local path = workingDir.."/bin/"..filename
        local fh, err = io.open(path, "w")
        if(err) then
            printError("Could not add dependency "..filename)
            error(err) 
        end
        fh:write(h.readAll())
        io.close(fh)
        print("Download complete")
    end
end



fs.makeDir(workingDir)
updatePath()
downloadDependencies()
fs.delete(shell.dir().."/install.lua")

print("Successfully installed, you can run using the 'ccpkg' command") 

