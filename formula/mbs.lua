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


function package:install(ccpkg, artifacts, version)
    shell.run(ccpkg.."/mbs.lua", "run")
end

function package:uninstall(ccpkg, version)
    fs.remove("/.mbs")
    fs.remove("/startup/00_mbs.lua")
    fs.remove("/mbs.lua")
end

return package