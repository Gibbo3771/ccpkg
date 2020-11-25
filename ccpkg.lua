            
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


local params = {...}
local ccpkg = {}

if(table.getn(params) == 0) then
    print("No command passed")
    return
end



local command = params[1]

local workingDir = "/ccpkg/"
local cachePath = workingDir.."cache/"
local tmpPath = workingDir.."tmp/"
local supportedFileTypes = { ".tar.gz" }
local color = term.isColor();

local PACKAGE_INSTALLED = 1
local PACKAGE_VERSION_MISMATCH = 2

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

local function endsWith(str, ending)
   return ending == "" or str:sub(-#ending) == ending
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

--
local function getFileTypeFromUrl(url)
    for _, t in pairs(supportedFileTypes) do
        if(endsWith(url, t)) then return t end
    end
    printError("Unsupported file type '"..url.."'")
    error("ccpkg does not know how to handle this type of file")
end

-- Parses the pkg.json file
-- @returns a table representation of the file
function ccpkg:parsePkgJson()
    local fh, err = io.open(workingDir.."/pkg.json", "r")
    if(err) then error(err) end
    local json = textutils.unserialiseJSON(fh:read())
    io.close(fh)
    return json
end

-- Updates the pkg.json file on file. This is a complete replacement.
-- @param pkg the contents to put into the file
-- @returns the updated file in json format
function ccpkg:updatePkgJson(pkg)
    local fh, err = io.open(workingDir.."/pkg.json", "w")
    if(err) then error(err) end
    local json = textutils.serializeJSON(pkg)
    fh:write(json)
    io.close(fh)
    return json
end

-- Adds a dependency to the pkg file
-- @param name the name of the package
-- @param version the version of the package
function ccpkg:addToPkgJson(name, version)
    local pkg = ccpkg:parsePkgJson()
    pkg.dependencies[name] = version
    ccpkg:updatePkgJson(pkg)
end

function ccpkg:isInstalled(package)
    local name, version = unpack(splitIntoNameAndVersion(package))
    local pkg = ccpkg:parsePkgJson()
     if(pkg.installed[name]) then
        if(pkg.installed[name] ~= version) then
            return PACKAGE_VERSION_MISMATCH
        else
            return PACKAGE_INSTALLED
        end
    else return 0 end
end

-- Downloads a formula from the main repository
-- @param name the name of the formula
-- @returns the compiled formula
function ccpkg:getFormula(name)
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

-- download the package
-- @param url the download url
-- @param version the version being downloaded
-- @param name the name of the package
function ccpkg:download(url, version, name)
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
        printError("Could write package tar to disk")
        error(err) 
    end
    fh:write(h.readAll())
    io.close(fh)
end

-- Extracts a .tar.gz archived package
-- @param name the name of the package
-- @param version the version of the package
-- @returns the path to the extracted archives
function ccpkg:extractTar(name, version)
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

-- Installs a package
-- @param package the name and semantic version separate by an @, or just the name
-- @param skipPkgUpdate if passed as true, updating the pkg json will be skipped
function ccpkg:install(package)    
    local name, version = unpack(splitIntoNameAndVersion(package))
    local formula = ccpkg:getFormula(name)
    -- If no version is passed, we set it to resolve
    -- to whatever version the formula specifies as "stable"
    if(version == "stable") then
        version = formula.stable()
    end
    
    local url = formula.versions[version]
    fileType = getFileTypeFromUrl(url)
    local file = retrieveFromCache(name)
    if(not file) then
        ccpkg:download(url, version, name)
    else
        log(colors.white, "Installing "..name.." from cache")
    end
    
    -- The location where the package artifacts will exist
    local artifacts = ccpkg:extractTar(name, version)
    artifacts = artifacts.."/"..name.."-"..version
    print(artifacts)
    
    formula:install(_ENV, self, artifacts, version)
    log(colors.green, name.." has been sucessfully installed") 
end

-- Removes an existing package as a dependency
-- @param name the name of the package
function ccpkg:remove(name)
    local pkg = ccpkg:parsePkgJson()
    local deps = pkg.dependencies
    if(not deps[name]) then
        log(colors.orange, "You do not have "..name.." as a dependency") 
    else
        local version = deps[name]
        local formula = ccpkg:getFormula(name)
        formula:uninstall(_ENV, self) 
        deps[name] = nil
        ccpkg:updatePkgJson(pkg)
        fs.delete(path..name)
        log(colors.lime, "Removed "..name.." successfully")
    end
end



if(command == "install") then
    local package = params[2]
    if(not package) then
        printError("You must specify a package name")
        return
    end
    local p = ccpkg:isInstalled(package)
    if(p == PACKAGE_INSTALLED) then log(colors.orange, "You already have "..name.."@"..version.." installed") return end
    if(p == PACKAGE_VERSION_MISMATCH) then log(colors.orange, "You already have this package installed as version '"..version.."'") return end
    ccpkg:install(package)
    log(colors.lime, "Finished, happy coding!")
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
    ccpkg:remove(package)
    return
end

log(colors.red, "Unrecongized command "..command)