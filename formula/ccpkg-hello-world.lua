-- This is an example formula you can use as a template, it is self documented and contains the most up to
-- date formula definition

-- This is the entry table and is used by ccpkg (and the doc page) for displaying info,
-- extrating versions and all the good stuff.
--
-- @field name [REQUIRED] The name of the package
-- @field description [REQUIRED] The description of the package
-- @field homepage [OPTIONAL] The homepage for the package
-- @field repository [OPTIONAL] The repository for the package
-- @field authors [OPTIONAL] An array of authors for this package
-- @field contributors [OPTIONAL] An array of contributors to this package
-- @field license [RECOMMENDED] The license that this package lives under
-- @field library [OPTIONAL, NOT YET IMPLEMENTED] If this package is a library, defaults to false.
-- @field target [RECOMMENDED, NOT YET IMPLEMENTED] Specify if this package was created for either 'computer', 'turtle' or '*' for any
-- @field versions [REQUIRED] A table of the available versions, where the key is the version number and the value is the download url
local package = {
    name = "ccpkg-hello-world",
    description = "This is an example formula", 
    homepage = "https://github.com/Gibbo3771/ccpkg-hello-world", 
    repository = "https://github.com/Gibbo3771/ccpkg-hello-world", 
    authors = { "Stephen Gibson" }, 
    contributors = { },
    license = "MIT",
    library = false,
    target = "*",
    versions = {
        ["3.0.0"] = "https://github.com/Gibbo3771/ccpkg-hello-world/archive/3.0.0.tar.gz",
        ["2.0.0"] = "https://github.com/Gibbo3771/ccpkg-hello-world/archive/2.0.0.tar.gz",
        ["1.0.0"] = "https://github.com/Gibbo3771/ccpkg-hello-world/archive/1.0.0.tar.gz"
    }
}

-- [REQUIRED]
-- Specifies the "stable" version of the package
function package:stable()
   return "3.0.0"
end

-- TODO
-- [OPTIONAL, NOT YET IMPLEMENTED]
-- This hook is called right before the package is installed
--
-- @param version the version about to be installed
function package:preInstall(version)
    -- Do some stuff
end

 -- [REQUIRED]
-- This hook is called during the installation of the package.
--
-- @param env the env that the script was executed from
-- @param ccpkg the ccpkg instance
-- @param artifacts the directory where the package artifacts are located
-- @param version the version of the package being installed
function package:install(env, ccpkg, artifacts, version)
    -- We move our script into the bin path so it's available globally
    env.fs.move(artifacts.."/say-hello.lua", "/ccpkg/bin/say-hello.lua")
end

-- TODO
-- [OPTIONAL, NOT YET IMPLEMENTED]
-- This hook is called right after the package has been installed
--
-- @param version the version that was just installed
function package:postInstall(version)
    -- Do some stuff
end

-- [REQUIRED]
-- This hook is called during the uninstallation of a package
--
-- @param env the env that the script was executed from
-- @param ccpkg the ccpkg instance
-- @param version the version of the package being uninstalled
function package:uninstall(env, ccpkg, version)
    -- We remove our script
    env.fs.delete("/ccpkg/bin/say-hello.lua")

end

-- [REQUIRED]
-- Always return your package table
return package