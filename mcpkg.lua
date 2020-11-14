local params = {...}

if(table.getn(params) == 0) then
    print("No command passed")
    return
end

local initFileContents = [=[
-- This is your entry file for your project. You should call this from your
-- startup file to get going
]=]

local command = params[1]

local path = shell.dir()
local vendorPath = path.."/vendor"
local varPath = path.."/var"

local function isProjectFolder()
    return fs.exists(path.."/pkg.json")
end

local function split(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end

local function new(name)
    function createPackageFile()
        local defaultPkgFile = {version = "1.0.0", name = name, dependencies = {}}
        fs.makeDir(vendorPath)
        fs.makeDir(varPath)

        local fh, err = io.open(path.."/pkg.json", "w")
        if(err) then
            printError("Could not create pkg file")
            error(err) 
        end
        fh:write(textutils.serializeJSON(defaultPkgFile))
        io.close(fh)
    end
    
    function createEntryFile()
        local fh, err = io.open(path.."/init.lua", "w")
        if(err) then
            printError("Could not create entry file")
            error(err) 
        end
        fh:write(initFileContents)
        io.close(fh)
    end
    
    print("Creating new project '"..name.."'")
    createPackageFile()
    createEntryFile()
end

local function add(package)
    
    function getFormula(name)
        print("Looking for formula '"..name.."'...")
        local req = http.get("https://raw.githubusercontent.com/Gibbo3771/pkgmc/main/formula/"..name..".lua")
        if(not req) then
            error("Could not download formula") 
        end
        print("Found '"..name.."'")
        return req.readAll()
    end
    
    function download(url, name)
        print("Downloading package '"..name.."'...")
        print(url:match("^.+/(.+)$"))
        local req = http.get(url)
        local fh, err = io.open(varPath.."/"..name.."-"..url:match("^.+/(.+)$"), "w")
        if(err) then
            printError("Could not create entry file")
            error(err) 
        end
        fh:write(initFileContents)
        io.close(fh)
        
    end
    
    function install()
        print("Installing "..arg.."...")
        
    end

    local name, version = unpack(split(package, "@"))
    if(not version) then version = "latest" end
    local formula = getFormula(name)
    local func, err = load(formula)
    if func then
        local ok, f = pcall(func)
        if ok then
            download(f.versions[version], name)
            f:install(version)
        else
            error("Could not execute formula")
        end
    else
        error("Could not compile formula")
    end
end



if(command == "new") then
    local name = params[2] or nil
    if(not name) then
        printError("You must specify a project name as the second argument")
        return
    end
    if(isProjectFolder()) then
        printError("A project has already been created in this directory")
        return
    end
    new(name)
    print("Finished, happy coding!")
    return
elseif(command == "add") then
    if(not isProjectFolder()) then
        printError("Not in a project directory, run 'mcpkg init <project-name>' before trying to add packages")
        return
    end
    local package = arg[2] or nil
    if(not package) then
        printError("Pass the name of the package you want to add")
        return
    end
    add(package)
    return
end

print("Unrecongized command "..command)