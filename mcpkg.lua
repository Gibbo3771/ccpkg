package.path = package.path .. ";" .. "/vendor/?;vendor/?.lua"
local params = {...}

if(table.getn(params) == 0) then
    print("No command passed")
    return
end

local command = params[1]
local arg = params[2]


local path = fs.getDir(shell.getRunningProgram())
local vendorPath = fs.getDir(shell.getRunningProgram()).."/vendor"


local function init()
    
    function writeDefaultFile()
        local defaultPkgFile = {version = "1.0.0", dependencies = {}}
        fs.makeDir(vendorPath)
        fs.makeDir(path.."/var")

        local fh, err = io.open(path.."/pkg.json", "w")
        if(err) then
            printError("Could not create pkg file")
            error(err) 
        end
        fh:write(textutils.serializeJSON(defaultPkgFile))
        io.close(fh)
    end
    
    print("Creating new project '"..arg.."'")
    writeDefaultFile()
end

local function install()
    print("Fetching master list...")
    print("Installing "..arg.."...")
end



if(command == "init") then
    if(not arg) then
        printError("You must specify a project name as the second argument when using init")
        return
    end
    if(fs.exists(path.."/pkg.json")) then
        printError("A project has already been created in this directory")
        return
    end
    init()
    print("Finished, happy coding!")
    return
elseif(command == "install") then
    if(not arg) then
        printError("Pass the name of the package you want to install")
        return
    end
    install()
    return
end

print("Unrecongized command "..command)