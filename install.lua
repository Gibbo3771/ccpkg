local params = {...}
local workingDir = "/ccpkg"

-- This will be injected into a default startup file
local startupContent = [=[
-- This file has been generated by ccpkg. You should not overwite it
-- but instead, extend it. Removing this file will break the autoloading
-- of ccpkg programs
local paths = {
    package.path,
    "/ccpgk/?.lua",
    "/ccpgk/?",
    "/ccpgk/global/vendor/?",
    "/ccpgk/global/vendor/?.lua"
}
package.path = table.concat(paths, ";")
shell.setPath(shell.path()..":".."/ccpkg/bin")  

-- Below here you can add your own code to run at startup
]=]

local function updatePath()
    local paths = {
        package.path,
        "/ccpgk/?.lua",
        "/ccpgk/?",
        "/ccpgk/global/vendor/?",
        "/ccpgk/global/vendor/?.lua"
    }
    package.path = table.concat(paths, ";")
    shell.setPath(shell.path()..":".."/ccpkg/bin") 
end

local function createDefaultStartupFile()
    if(fs.exists("/startup")) then
        print("Detected exisiting startup file, backing it up to /startup.bak.lua")
        fs.move("/startup", "/startup.bak.lua")
    end
    local fh, err = io.open("/startup.lua", "w")
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



fs.makeDir(workingDir)
fs.makeDir(workingDir.."/cache")

createDefaultStartupFile()
updatePath()
downloadDependencies()
print("Cleaning up")
fs.delete(shell.dir().."/install.lua")

print("Would you like to enable global packages? (y/n)")
local answer
while(answer ~= "y" and answer ~= "n") do
    answer = read()
    if(answer == "y") then
        local oldDir = shell.resolve(shell.dir())
        fs.makeDir(workingDir.."/global")
        shell.setDir(workingDir.."/global")
        shell.run("ccpkg", "new", "global")
        fs.delete(shell.resolve("init.lua"))
        shell.setDir(oldDir)
        print("Globals are now enabled")
    elseif(answer == "n") then
        -- Do nothing
    else
        print("Please answer using either 'y' or 'n'")
    end
end
print("Successfully installed, you can run using the 'ccpkg' command")

