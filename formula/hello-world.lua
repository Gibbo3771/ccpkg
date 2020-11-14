local helloWorld = {
    name = "hello-world",
    description = "This is an example formula",
    versions = {
        latest = "https://github.com/Gibbo3771/mcpkg-hello-world/archive/2.0.0.tar.gz",
        ["1.0.0"] = "https://github.com/Gibbo3771/mcpkg-hello-world/archive/1.0.0.tar.gz"
    }
}

-- Install the formula, mcpkg will automatically add
-- the package to the vendor/<package-name>/ folder
-- under your project, any extra installation steps should
-- be done here
function helloWorld:install()
    
end

return helloWorld