-- This is an example formula you can use as a template, it is self documented and contains the most up to
-- date formula definition

local package = { -- [REQUIRED] The table that ccpkg will require when it downloads the formula and compiles it
    name = "ccpkg-hello-world", -- [REQUIRED] The name of the package
    description = "This is an example formula", -- [REQUIRED] The description of the package
    homepage = "https://github.com/Gibbo3771/ccpkg-hello-world", -- [OPTIONAL] The homepage for the package
    repository = "https://github.com/Gibbo3771/ccpkg-hello-world", -- [OPTIONAL] The repository for the package
    authors = { "Stephen Gibson" }, -- [OPTIONAL] An array of authors for this package
    contributors = { },  -- [OPTIONAL] An array of contributors to this package
    license = "MIT",  -- [RECOMMENDED] The license that this package lives under
    library = false,  -- [OPTIONAL, NOT YET IMPLEMENTED] If this package is a library, defaults to false.
    target = "*", -- [RECOMMENDED, NOT YET IMPLEMENTED] Specify if this package was created for either 'computer', 'turtle' or '*' for any
    versions = { -- [REQUIRED] A table of the available versions, where the key is the version number and the value is the download url
        ["3.0.0"] = "https://github.com/Gibbo3771/ccpkg-hello-world/archive/3.0.0.tar.gz",
        ["2.0.0"] = "https://github.com/Gibbo3771/ccpkg-hello-world/archive/2.0.0.tar.gz",
        ["1.0.0"] = "https://github.com/Gibbo3771/ccpkg-hello-world/archive/1.0.0.tar.gz"
    }
}

function package:stable() -- [REQUIRED] Specifies the "stable" version of the package
   return "3.0.0"
end

-- TODO
-- This hook is called right before the package is installed
function package:preInstall(version)  -- [OPTIONAL, NOT YET IMPLEMENTED] A pre install hook
    -- Do some stuff
end

-- This hook is called during the installation of the package.
-- @param env the env that the script was executed from
-- @param ccpkg the ccpkg instance
-- @param artifacts the directory where the package artifacts are located
-- @param version the version of the package being installed
function package:install(env, ccpkg, artifacts, version)  -- [REQUIRED]
    -- We move our script into the bin path so it's available globally
    env.fs.move(artifacts.."/say-hello.lua", "/ccpkg/bin/say-hello.lua")
end

-- TODO
-- This hook is called right after the package has been installed
function package:postInstall(version)  -- [OPTIONAL, NOT YET IMPLEMENTED] A post install hook
    -- Do some stuff
end

-- This hook is called during the uninstallation of a package
-- @param env the env that the script was executed from
-- @param ccpkg the ccpkg instance
-- @param version the version of the package being uninstalled
function package:uninstall(env, ccpkg, version)  -- [REQUIRED]
    -- We remove our script
    env.fs.delete("/ccpkg/bin/say-hello.lua")

end

return package  -- [REQUIRED] Always return your package table