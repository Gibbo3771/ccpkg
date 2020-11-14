local helloWorld = {
    name = "hello-world",
    description = "This is an example formula",
    versions = {
        latest = "https://github.com/Gibbo3771/mcpkg-hello-world/archive/2.0.0.tar.gz",
        ["1.0.0"] = "https://github.com/Gibbo3771/mcpkg-hello-world/archive/1.0.0.tar.gz"
    }
}

-- Install the formula
function helloWorld:install()
    
end

return helloWorld