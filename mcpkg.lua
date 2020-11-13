local params = {...}

if(table.getn(params) == 0) then
    print("No command passed")
    return
end

local command = params[1]
local arg = params[2]


local path = fs.getDir(shell.getRunningProgram())
local vendorPath = fs.getDir(shell.getRunningProgram()).."/vendor"
local tmpPath = fs.getDir(shell.getRunningProgram()).."/tmp"

local function isProjectFolder()
    return fs.exists(path.."/pkg.json")
end

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
    
    function getFormula()
        local req = http.get("https://github.com/Gibbo3771/pkgmc/blob/main/formula/"..arg)
        if(not req) then
            error("Could not download formula") 
        end
        local fh, err = io.open(tmpPath.."/"..arg.."/"..arg..".lua", "w")
        if(err) then
            printError("Could not create pkg file")
            error(err) 
        end
        fh:write(req.readAll())
        io.close(fh)
    end
    
    function download()
        local zip = http.get("https://github.com/Gibbo3771/pkgmc/blob/main/mcpkg.lua")
        
    end
    
    function install()
        print("Installing "..arg.."...")
        
    end
    
    getFormula()
end



if(command == "init") then
    if(not arg) then
        printError("You must specify a project name as the second argument when using init")
        return
    end
    if(isProjectFolder()) then
        printError("A project has already been created in this directory")
        return
    end
    init()
    print("Finished, happy coding!")
    return
elseif(command == "install") then
    if(not isProjectFolder()) then
        printError("Not in a project directory, run 'mcpkg init <project-name>' before trying to install packages")
        return
    end
    if(not arg) then
        printError("Pass the name of the package you want to install")
        return
    end
    install()
    return
end

print("Unrecongized command "..command)