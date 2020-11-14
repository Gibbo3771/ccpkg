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

local function add()
    
    function getFormula()
        print("Looking for formula '"..arg.."'")
        local req = http.get("https://raw.githubusercontent.com/Gibbo3771/pkgmc/main/formula/"..arg..".lua")
        if(not req) then
            error("Could not download formula") 
        end
        print("Found '"..arg.."'")
        local fh, err = io.open(tmpPath.."/"..arg.."/"..arg..".lua", "w")
        if(err) then
            printError("Could not add formula")
            error(err) 
        end
        fh:write(req.readAll())
        io.close(fh)
    end
    
    function download()
        print("Downloading package")
        local formula = require(tmpPath.."/"..arg.."/"..arg)
        
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
elseif(command == "add") then
    if(not isProjectFolder()) then
        printError("Not in a project directory, run 'mcpkg init <project-name>' before trying to add packages")
        return
    end
    if(not arg) then
        printError("Pass the name of the package you want to add")
        return
    end
    add()
    return
end

print("Unrecongized command "..command)