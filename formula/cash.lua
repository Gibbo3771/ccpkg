local package = {
    name = "cash",
    description = "A Bourne-compatible shell for ComputerCraft.",
    homepage = "https://github.com/Gibbo3771/cash",
    repository = "https://github.com/Gibbo3771/cash",
    authors = { "MCJack123" },
    license = "MIT",
    library = false,
    versions = {
        ["0.3.0"] = "https://github.com/Gibbo3771/cash/archive/0.3.0.tar.gz",
    }
}

function package:stable()
   return "0.3.0"
end


function package:install(env, ccpkg, artifacts, version)
    local fs = env.fs
    fs.move(artifacts.."/cash.lua", "/ccpkg/bin/cash.lua")
end

function package:uninstall(env, ccpkg, version)
    local fs = env.fs
    fs.delete("/ccpkg/bin/cash.lua")
end

return package