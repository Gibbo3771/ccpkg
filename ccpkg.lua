local params = {...}
local ccpkg = {}

if(table.getn(params) == 0) then
    print("No command passed")
    return
end

local initFileContents = [=[
-- ______             _       _                                  _ 
-- | ___ \           | |     | |                                | |
-- | |_/ / ___   ___ | |_ ___| |_ _ __ __ _ _ __  _ __   ___  __| |
-- | ___ \/ _ \ / _ \| __/ __| __| '__/ _` | '_ \| '_ \ / _ \/ _` |
-- | |_/ / (_) | (_) | |_\__ \ |_| | | (_| | |_) | |_) |  __/ (_| |
-- \____/ \___/ \___/ \__|___/\__|_|  \__,_| .__/| .__/ \___|\__,_|
--                                         | |   | |               
--                                         |_|   |_|               
--                 _                              _                
--                (_)                            | |               
--       _   _ ___ _ _ __   __ _    ___ ___ _ __ | | ____ _        
--      | | | / __| | '_ \ / _` |  / __/ __| '_ \| |/ / _` |       
--      | |_| \__ \ | | | | (_| | | (_| (__| |_) |   < (_| |       
--       \__,_|___/_|_| |_|\__, |  \___\___| .__/|_|\_\__, |       
--                          __/ |          | |         __/ |       
--                         |___/           |_|        |___/        
--
--
-- Created By: Stephen Gibson
-- Github: https://github.com/Gibbo3771/ccpkg
-- Docs: https://github.com/Gibbo3771/ccpkg/blob/main/README.md
-- Issues: https://github.com/Gibbo3771/ccpkg/issues
-- 
--
-- This is your entry file for your project.
-- You can call this from your startup file or call it directly from
-- the terminal.

-- AUTO GENERATED DO NOT EDIT OR DELETE
-- If you must modify the path, ensure you do not remove existing entries
-- as this will break ccpkg module resolution
local paths = {
    "/#{path}/vendor/?.lua", -- Always resolve local modules first
    "/#{path}/vendor/?",
    "/ccpkg/?.lua",
    "/ccpkg/?",
    "/ccpkg/global/vendor/?",
    "/ccpkg/global/vendor/?.lua",
    package.path,
}
package.path = table.concat(paths, ";")

-- You can add your code below this comment
]=]

local startupFileContents = [=[
-- AUTO GENERATED DO NOT EDIT OR DELETE
-- If you must modify the path, ensure you do not remove existing entries
-- as this will break ccpkg module resolution
local paths = {
    "/#{path}/init.lua", -- Resolve the init file
    "/#{path}/init",
    package.path,
}
package.path = table.concat(paths, ";")

-- Load your script on startup
require("#{init}")
]=]

local command = params[1]

local path = shell.dir()
local vendorPath = path.."/vendor/"
local cachePath = "/ccpkg/cache/"
local tmpPath = "/ccpkg/tmp/"
local globalPath = "/ccpkg/global/"

-- If global has been passed as the base command
local isGlobal = false
local noStartup = false
local color = term.isColor();

local function log(color, message)
    if(color) then
        local oc = term.getTextColor()
        term.setTextColor(color)
        print(message)
        term.setTextColor(oc)
    else
        print(message)
    end
end

-- Check if the current folder is a valid project directory
-- @returns
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

-- Splits the package name from the version number
-- @param package the string contain the package name and version separated by an @
local function splitIntoNameAndVersion(package)
    local pkg = split(package, "@")
    if(not pkg[2]) then pkg[2] = "stable" end
    return pkg
end

-- A helper that resolves the project path depending on the 
-- global flag
-- @param path the path to resolve
local function resolvePath(path)
    if(isGlobal) then return globalPath..path else return shell.resolve(path) end
end

-- Iterates over all the files present in the cache and attempts
-- the find one with the name provided using the format pattern.
-- @param name the name of the package
-- @returns the full filename of the package if it exissts in the cache
local function retrieveFromCache(name)
    local list = fs.list(cachePath)
    for _, sFileName in pairs(list) do
        local sCutName = fs.getName(sFileName)
        if sCutName:match("(.+)%-.+") == name then
            return sFileName
        end
    end
end

-- Parses the pkg.json file
-- @returns a table representation of the file
function ccpkg.parsePkgJson()
    local fh, err = io.open(resolvePath("pkg.json"), "r")
    if(err) then error(err) end
    local json = textutils.unserialiseJSON(fh:read())
    io.close(fh)
    return json
end

-- Updates the pkg.json file on file. This is a complete replacement.
-- @param pkg the contents to put into the file
-- @returns the updated file in json format
function ccpkg.updatePkgJson(pkg)
    local fh, err = io.open(resolvePath("pkg.json"), "w")
    if(err) then error(err) end
    local json = textutils.serializeJSON(pkg)
    fh:write(json)
    io.close(fh)
    return json
end

-- Adds a dependency to the pkg file
-- @param name the name of the package
-- @param version the version of the package
function ccpkg.addToPkgJson(name, version)
    local pkg = ccpkg.parsePkgJson()
    if(pkg.dependencies[name]) then
        if(pkg.dependencies[name] ~= version) then
            log(colors.orange, "You already have this package installed as version '"..version.."'")
        else
            if(isGlobal) then
                log(colors.orange, "You already have "..name.."@"..version.." installed globally")
            else
                log(colors.orange, "You already have "..name.."@"..version.." as a dependency")
            end
        end
        -- TODO graceful failures
        error()
    else
        pkg.dependencies[name] = version
    end
    ccpkg.updatePkgJson(pkg)
end

-- Downloads a formula from the main repository
-- @param name the name of the formula
-- @returns the compiled formula
function ccpkg.getFormula(name)
    log(colors.white, "Looking for formula '"..name.."'...")
    local req = http.get("https://raw.githubusercontent.com/Gibbo3771/ccpkg/main/formula/"..name..".lua")
    if(not req) then
        error("Could not download formula") 
    end
    log(colors.lime, "Found '"..name.."'")
    local func, err = load(req.readAll())
    if func then
        local ok, f = pcall(func)
        if ok then
            return f
        else
            error("Could not execute formula")
        end
    else
        error("Could not compile formula")
    end
end

-- download the tar.gz from the github release
-- @param url the download url
-- @param versionthe version being downloaded
-- @param name the name of the package
function ccpkg.download(url, version, name)
    log(colors.white, "Downloading package '"..name.."'...")
    local path = cachePath..name.."-"..version
    local h, err, res = http.get(url, nil, true)
    if(not h) then
        log(colors.red, "Error downloading "..name)
        log(colors.red, "Error: "..err..". ".."HTTP Code: "..res.getResponseCode())
        error("Failed to download, exiting")
    end
    local fh, err = io.open(path..".tar.gz", "wb")
    if(err) then
        printError("Could not create entry file")
        error(err) 
    end
    fh:write(h.readAll())
    io.close(fh)
end


-- Creates a new project.
-- This will create a new project in the current directory, it will generate a pkg.json, a vendor folder
-- and an init.lua entry file.
-- The user will be prompted if they would like to create a startup file for the project, enableing autorun
-- when the machine comes online. If the --no-startup flag is passed to ccpkg when creating a new project, this 
-- question will be skipped.
-- @param name the name of the project, this will fill in the 'name' field in the pkg.json
-- @throws if it can not create a pkg.json file, or an init.lua entry file, or if it can't create a startup file
function ccpkg.new(name)
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
        local injected = initFileContents:gsub("#{path}", shell.dir())
        fh:write(injected)
        io.close(fh)
    end
    
    log(colors.white, "Creating new project '"..name.."'")
    createPackageFile()
    createEntryFile()
    local pkg = ccpkg.parsePkgJson()
    ccpkg.updatePkgJson(pkg)
    if(not noStartup) then
        log(colors.cyan, "Would you like to create a startup file for this project? (this will automatically start it on boot) (y/n)")
        local answer
        local startupFilename = "/startup/90_"..name.."-start.lua"
        while(answer ~= "y" and answer ~= "n") do
            answer = read()
            if(answer == "y") then
                local injected = startupFileContents:gsub("#{path}", shell.dir()):gsub("#{init}", shell.resolve("init.lua"):gsub("/", "."))
                local fh, err = io.open(startupFilename, "w")
                if(err) then
                    printError("Could not create startup file")
                    error(err) 
                end
                fh:write(injected)
                io.close(fh)
                log(colors.lime, "Created startup file as "..startupFilename.." in /startup")
            elseif(answer == "n") then
                -- Do nothing
            else
                log(colors.red, "Please answer using either 'y' or 'n'")
            end
        end
    end
end

-- Extracts a .tar.gz archived package
-- @param name the name of the package
-- @param version the version of the package
-- @returns the path to the extracted archives
function ccpkg.extractTar(name, version)
    local tar = require("tar")
    local tar = require("tar")
    log(colors.white, "Decompressing archive..")
    local t = tar.decompress(cachePath..name.."-"..version..".tar.gz")
    t = tar.load(t, false, true)
    log(colors.white, "Extracting archive")
    local tmp = tmpPath..name -- tmp directory just for this package download
    fs.makeDir(tmp)
    tar.extract(t, tmp)
    return tmp
end

-- Includes the specified package in the project
-- @param artifacts the path to the package artifacts
-- @param name the name of the package
-- @param version the version of the package
function ccpkg.include(artifacts, name, version)
    local destination
    if(isGlobal) then destination = globalPath.."/vendor/" else destination = vendorPath end
    
    local files = fs.list(artifacts)
    -- When downloaded from github the tar contains a version
    -- folder, we remove the version number to allow
    -- module references
    for _, file in pairs(files) do
       if(string.find(file, name, 1, true)) then
            fs.move(artifacts.."/"..file, destination..name)
        end
    end
    fs.delete(artifacts)
end

-- Adds a new package
-- @param package the name and semantic version separate by an @, or just the name
-- @param skipPkgUpdate if passed as true, updating the pkg json will be skipped
function ccpkg.add(package, skipPkgUpdate)    
    local name, version = unpack(splitIntoNameAndVersion(package))
    local formula = ccpkg.getFormula(name)
    -- If no version is passed, we set it to resolve
    -- to whatever version the formula specifies as "stable"
    if(version == "stable") then
        version = formula.stable()
    end
    local file = retrieveFromCache(name)
    if(not file) then
        ccpkg.download(formula.versions[version], version, name)
    else
        log(colors.white, "Installing "..name.." from cache")
    end
    
    local artifacts = ccpkg.extractTar(name, version)
    -- If the formula specifies an install function, we let that run instead
    if(formula.install) then
        formula.install(ccpkg, artifacts, version)
    else
        ccpkg.include(artifacts, name, version)
    end
    
    if(not skipPkgUpdate) then 
        ccpkg.addToPkgJson(name, version) 
        if(not isGlobal) then 
            log(colors.green, name.." has been added to your project as a dependency") 
        else 
            log(colors.green, name.." has been added globally") 
        end
    end
end

-- Removes an existing package as a dependency
-- @param name the name of the package
function ccpkg.remove(name)
    local path
    if(isGlobal) then path = globalPath.."/vendor/" else path = vendorPath end
    local pkg = ccpkg.parsePkgJson()
    local deps = pkg.dependencies
    if(not deps[name]) then
        log(colors.orange, "You do not have "..name.." as a dependency") 
    else
        local version = deps[name]
        deps[name] = nil
        ccpkg.updatePkgJson(pkg)
        fs.delete(path..name)
        log(colors.lime, "Removed "..name.." successfully")
    end
end

-- Installs all the dependencies specified in the pkg.json
function ccpkg.installFromPkg()
    log(colors.white, "Installing dependencies")
    local pkg = ccpkg.parsePkgJson()
    local noop = true
    for name, version in pairs(pkg.dependencies) do
        if(not fs.exists(vendorPath..name)) then 
            noop = false
            ccpkg.add(name.."@"..version, true)
        end
    end
    if(noop) then log(colors.limed, "Up to date!") end
end

-- Runs a local file using ccpkg. This handles setting `package.path` so that
-- ccpkg can resolve packages in the local project, or in the global
function ccpkg.run()
    table.remove(params, 1) -- 'run' arg
    local program = params[1]
    table.remove(params, 1) -- program name
    local paths
        paths = {
            "/"..shell.dir().."/vendor/?.lua", -- Always resolve local modules first
            "/"..shell.dir().."/vendor/?",
            "/ccpkg/?.lua",
            "/ccpkg/?",
            "/ccpkg/global/vendor/?",
            "/ccpkg/global/vendor/?.lua",
            package.path,
        }
    package.path = table.concat(paths, ";")
    local programPath
    if(fs.exists(shell.resolve(program))) then
        programPath = "/"..shell.resolve(program)
    elseif(fs.exists(shell.resolve(program..".lua"))) then
        programPath = "/"..shell.resolve(program)..".lua"
    else
        error("Could not find "..program..". Are you in the correct directory?")
    end
    os.run(_ENV, programPath, (unpack(params)))
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
    local flag = params[3] or nil
    for _, flag in ipairs(params) do
        if(flag == "--no-startup") then noStartup = true end
    end
    ccpkg.new(name)
    log(colors.lime, "Finished, happy coding!")
    return
elseif(command == "add") then
    local sub = params[2] or nil  -- subcommand
    local package
    if(sub and sub == "global") then 
        isGlobal = true
        package = params[3] -- the package to remove
    else
        package = params[2] -- no global sub command, second arg must be the package
    end
    if(not isProjectFolder() and not isGlobal) then
        printError("Not in a project directory, run 'ccpkg new <project-name>' before trying to add packages")
        return
    end
    if(not package) then
        printError("Pass the name of the package you want to add")
        return
    end
    ccpkg.add(package)
    return
elseif(command == "remove") then
    local sub = params[2] or nil -- subcommand
    local package
    if(sub and sub == "global") then 
        isGlobal = true
        package = params[3] -- the package to remove
    else
        package = params[2] -- no global sub command, second arg must be the package
    end
    if(not isProjectFolder() and not isGlobal) then
        printError("Not in a project directory, run 'ccpkg new <project-name>'")
        return
    end
    ccpkg.remove(package)
    return
elseif(command == "install") then
    ccpkg.installFromPkg()
    return
elseif(command == "run") then
    ccpkg.run()
    return
end

log(colors.red, "Unrecongized command "..command)