local package = {
    name = "mbs",
    description = "MBS is a series of utilities for improving the default CraftOS experience.",
    homepage = "https://github.com/Gibbo3771/mbs",
    repository = "https://github.com/Gibbo3771/mbs",
    authors = { "Jonathan Coates" },
    license = "MIT",
    library = false,
    versions = {
        ["1.0.0"] = "https://github.com/Gibbo3771/mbs/archive/1.0.0.tar.gz",
    }
}

function package:stable()
   return "1.0.0"
end


function package:install(env, ccpkg, artifacts, version)
    local fs = env.fs
    fs.makeDir("/.mbs")
    fs.makedir("/ccpkg/lib/mbs")
    fs.move(artifacts.."/bin", "/.mbs/bin")
    fs.move(artifacts.."/lib", "/.mbs/lib")
    fs.move(artifacts.."/modules", "/.mbs/modules")
    env.fs.move(artifacts.."/mbs.lua", "/ccpkg/lib/mbs/mbs.lua")
    
    local handle = fs.open("startup/00_mbs.lua", "w")
    handle.writeLine(("assert(loadfile('/ccpkg/lib/mbs/mbs.lua', _ENV))('startup', '/ccpkg/lib/mbs/mbs.lua')"))
    handle.close()
end

function package:uninstall(env, ccpkg, version)
    local fs = env.fs
    fs.delete("/.mbs")
    fs.delete("/startup/00_mbs.lua")
    fs.delete("/ccpkg/lib/mbs")
end

return package