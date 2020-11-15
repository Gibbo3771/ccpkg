local helloWorld = {
    name = "ccpkg-hello-world",
    description = "This is an example formula",
    versions = {
        ["2.0.0"] = "https://github.com/Gibbo3771/ccpkg-hello-world/archive/2.0.0.tar.gz",
        ["1.0.0"] = "https://github.com/Gibbo3771/ccpkg-hello-world/archive/1.0.0.tar.gz"
    }
}

function helloWorld:stable()
   return helloWorld.versions["2.0.0"] 
end

-- Install the formula, mcpkg will automatically add
-- the package to the vendor/<package-name>/ folder
-- under your project, any extra installation steps should
-- be done here
function helloWorld:install(version)
    -- TODO
    -- local vendorPath = shell.dir()
    -- fs.move(vendorPath.."/".."mcpkg-hello-world-"..verson, vendorPath.."/".."hello-world")
end

return helloWorld