local params = {...}
local workingDir = "/ccpkg"

local startupContent = [=[            
--                           _                
--                          | |               
--             ___ ___ _ __ | | ____ _        
--            / __/ __| '_ \| |/ / _` |       
--           | (_| (__| |_) |   < (_| |       
--            \___\___| .__/|_|\_\__, |       
--                    | |         __/ |       
--                    |_|        |___/        
--
--      The package manager for ComputerCraft
--
-- Created By: Stephen Gibson
-- Github: https://github.com/Gibbo3771/ccpkg
-- Docs: https://github.com/Gibbo3771/ccpkg/blob/main/README.md
-- Issues: https://github.com/Gibbo3771/ccpkg/issues
-- 
--
-- This is a startup file to ensure ccpkg is loaded into the path properly

-- AUTO GENERATED DO NOT EDIT OR DELETE
-- If you must modify the path, ensure you do not remove existing entries
-- as this will break ccpkg module resolution
local paths = {
    "/ccpkg/lib/?.lua",
    "/ccpkg/lib/?",
    package.path,
}
package.path = table.concat(paths, ";")
shell.setPath(shell.path()..":".."/ccpkg/bin")  
]=]


local function updatePath()
    shell.setPath(shell.path()..":".."/ccpkg/bin") 
end

local function createStartupFile()
    if(fs.exists("/startup") and not fs.dir("/startup")) then
        print("Detected existing startup file. Moving it to /startup/90_startup.lua")
        fs.move("/startup", "/startup/90_startup.lua")
    end
    if(fs.exists("/startup.lua")) then
        print("Detected existing startup file. Moving it to /startup/90_startup.lua")
        fs.move("/startup.lua", "/startup/90_startup.lua")
    end
    local fh, err = io.open("/startup/10_ccpkg.lua", "w")
        if(err) then
            printError("Could not create startup file")
            error(err) 
        end
    fh:write(startupContent)
    io.close(fh)
end

local function downloadDependencies()
    print("Downloading dependencies...")
    local deps = {
        "https://raw.githubusercontent.com/Gibbo3771/CC-Archive/master/LibDeflate.lua",
        "https://raw.githubusercontent.com/Gibbo3771/CC-Archive/master/tar.lua",
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

local function createPackageFile()
    local defaultPkgFile = {installed = {}}
    local fh, err = io.open(workingDir.."/pkg.json", "w")
    if(err) then
        printError("Could not create pkg file")
        error(err) 
    end
    fh:write(textutils.serializeJSON(defaultPkgFile))
    io.close(fh)
end

fs.makeDir(workingDir)
fs.makeDir(workingDir.."/cache")
fs.makeDir(workingDir.."/tmp")
fs.makeDir(workingDir.."/lib")

createStartupFile()
createPackageFile()
updatePath()
downloadDependencies()

print("Cleaning up")
fs.delete(shell.dir().."/install.lua")
print("Successfully installed, you can run using the 'ccpkg' command")

