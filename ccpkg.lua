local params = {...}

if(table.getn(params) == 0) then
    print("No command passed")
    return
end

local initFileContents = [=[
-- This is your entry file for your project. You should call this from your
-- startup file to get going
local paths = {
    package.path,
    "/#{path}/vendor/?.lua",
    "/#{path}/vendor/?",
}
package.path = table.concat(paths, ";") 
]=]

local command = params[1]

local path = shell.dir()
local vendorPath = path.."/vendor"
local cachePath = "/ccpkg/cache"

local function isProjectFolder()
    print(path)
    return fs.exists(path.."/pkg.json")
end

local function split(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end

-- Splits the package name from the version number
-- @param package the string contain the package name and version separated by an @
local function splitIntoNameAndVersion(package)
    local pkg = split(package, "@")
    if(not pkg[2]) then pkg[2] = "stable" end
    return pkg
end

local function parsePkgJson()
    local fh, err = io.open(shell.resolve("pkg.json"), "r")
    if(err) then print(err) end
    local json = textutils.unserialiseJSON(fh:read())
    io.close(fh)
    return json
end

local function updatePkgJson(pkg)
    local fh, err = io.open(shell.resolve("pkg.json"), "w")
    if(err) then print(err) end
    local json = textutils.serializeJSON(pkg)
    fh:write(json)
    io.close(fh)
    return json
end

-- Adds a dependency to the pkg file
-- @param name the name of the package
-- @param version the version of the package
local function addToPkgJson(name, version)
    local pkg = parsePkgJson()
    if(pkg.dependencies[name]) then    
--        TODO check version differences
--        if(pkg.dependencies[name] ~= version) then
--        else
            print("You already have "..name.."@"..version.." as a dependency")
            error()
--        end
    else
        pkg.dependencies[name] = version
    end
    updatePkgJson(pkg)
end

-- TODO if created with the current directory as the name argument, we
-- we should use the folder name as the project name, if anything else
-- we should create a folder for it instead
--
-- Creates a new project
-- @param name the name of the project
local function new(name)
    function createPackageFile()
        local defaultPkgFile = {version = "1.0.0", name = name, dependencies = {}}
        fs.makeDir(vendorPath)

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
        fh:write(initFileContents:gsub("#{path}", shell.dir()))
        io.close(fh)
    end
    
    print("Creating new project '"..name.."'")
    createPackageFile()
    createEntryFile()
end

-- Downloads a formula from the main repository
-- @param name the name of the formula
local function getFormula(name)
    print("Looking for formula '"..name.."'...")
    local req = http.get("https://raw.githubusercontent.com/Gibbo3771/ccpkg/main/formula/"..name..".lua")
    if(not req) then
        error("Could not download formula") 
    end
    print("Found '"..name.."'")
    return req.readAll()
end

-- download the tar.gz from the github release
-- @param url the download url
-- @param versionthe version being downloaded
-- @param name the name of the package
local function download(url, version, name)
    print("Downloading package '"..name.."'...")
    local path = cachePath.."/"..name.."-"..version
    local req = http.get(url, nil, true)
    local fh, err = io.open(path..".tar.gz", "wb")
    if(err) then
        printError("Could not create entry file")
        error(err) 
    end
    fh:write(req.readAll())
    io.close(fh)
end

-- Installs a package for a project
-- @param name the name of the package
-- @param version the version
-- @param name the name of the package
-- @param path the location of the package artifacts
local function install(name, version, path)
    local tar = require("tar")
    print("Installing")
    print("Decompressing archive..")
    local t = tar.decompress(path..".tar.gz")
    t = tar.load(t, false, true)
    print("Extracting archive to "..vendorPath.."/"..name)
    tar.extract(t, vendorPath.."/")
    local files = fs.list(vendorPath.."/")
    -- When downloaded from github the tar contains a version
    -- folder, we remove the version number to allow
    -- module references
    for _, file in pairs(files) do
       if(string.find(file, name, 1, true)) then
            fs.move(vendorPath.."/"..file, vendorPath.."/"..name)
        end
    end
end

local function add(package)    
    local name, version = unpack(splitIntoNameAndVersion(package))
    local formula = getFormula(name)
    local func, err = load(formula)
    if func then
        local ok, f = pcall(func)
        if ok then
            -- If no version is passed, we set it to resolve
            -- to whatever version the formula specifies as "stable"
            if(version == "stable") then
                version = f.stable()
            end
            addToPkgJson(name, version)
            download(f.versions[version], version, name)
            install(name, version, cachePath.."/"..name.."-"..version)
        else
            error("Could not execute formula")
        end
    else
        error("Could not compile formula")
    end
    print(name.." has been added to your project as a dependency")
end

local function remove(name)
    local pkg = parsePkgJson()
    local deps = pkg.dependencies
    if(not deps[name]) then
        print("You do not have "..name.." as a dependency") 
    else
        deps[name] = nil
        updatePkgJson(pkg)
        fs.delete(vendorPath.."/"..name)
        print("Removed successfully")
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
        printError("Not in a project directory, run 'ccpkg new <project-name>' before trying to add packages")
        return
    end
    local package = arg[2] or nil
    if(not package) then
        printError("Pass the name of the package you want to add")
        return
    end
    add(package)
    return
elseif(command == "remove") then
    if(not isProjectFolder()) then
        printError("Not in a project directory, run 'ccpkg new <project-name>' before trying to add packages")
        return
    end
    local package = arg[2] or nil
    if(not package) then
        printError("Pass the name of the package you want to remove")
        return
    end
    remove(package)
    return
end

print("Unrecongized command "..command)