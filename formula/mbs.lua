local package = {
    name = "mbs",
    description = "MBS is a series of utilities for improving the default CraftOS experience.",
    homepage = "https://github.com/Gibbo3771/mbs",
    repository = "https://github.com/Gibbo3771/mbs",
    authors = { "Jonathan Coates" },
    license = "MIT",
    globalOnly = true,
    versions = {
        ["1.0.0"] = "https://github.com/Gibbo3771/mbs/archive/1.0.0.tar.gz",
    }
}

function package:stable()
   return "1.0.0"
end


function package:install(env, ccpkg, artifacts, version)
    env.shell.run(artifacts..name.."-"..version.."/mbs.lua", "install")
end

function package:uninstall(env, ccpkg, version)
    local fs = env.fs
    fs.delete("/.mbs")
    fs.delete("/startup/00_mbs.lua")
    fs.delete("/mbs.lua")
end

return package