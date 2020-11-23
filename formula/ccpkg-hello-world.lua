local helloWorld = {
    name = "ccpkg-hello-world",
    description = "This is an example formula",
    versions = {
        ["2.0.0"] = "https://github.com/Gibbo3771/ccpkg-hello-world/archive/2.0.0.tar.gz",
        ["1.0.0"] = "https://github.com/Gibbo3771/ccpkg-hello-world/archive/1.0.0.tar.gz"
    }
}

function helloWorld:stable()
   return "2.0.0"
end

-- TODO
-- This hook is called right after the package has been installed
function helloWorld:postInstall(version)
    -- Do some stuff
end

-- TODO
-- This hook is called during the installation of the package, if it
-- exists on the formula, this will be ran instead of ccpkg install
-- code, allowing custom installations
function helloWorld:install(ccpkg, artifacts, version)
    -- As an example, we don't actually do anything custom, we just include
    -- the package as normal
    ccpkg.include(artifacts, self.name, version)
end

-- TODO
-- This hook is called right before the package is installed
function helloWorld:preInstall(version)
    -- Do some stuff
end

return helloWorld