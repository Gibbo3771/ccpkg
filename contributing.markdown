---
layout: default
---

## Contributing

Adding your own packages to the repository is easy. If you are familiar with Github forking and Pull Requests, you can get going in just a few minutes.

You will require knowledge of ComputerCraft, as each **formula** works by exposing an **install** and **uninstall** hook. These are called by `ccpkg` once your package has been extracted to an artifact directory.

### Formula

The anatomy of a Formula file, comments explain each section, however I have also extracted out certain ones below for cover more details. This formula has been taken from the [ccpkh-hello-world]({{ "/formula/ccpkg-hello-world" | absolute_url }}) formula:

```lua
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
    library = false,  -- [OPTIONAL] If this package is a library, defaults to false.
    target = "*" -- [RECOMMENDED] Specify if this package was created for either 'computer', 'turtle' or '*' for any
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
function package:preInstall(version)  -- [OPTIONAL] A pre install hook
    -- Do some stuff
end

-- This hook is called during the installation of the package, if it
-- exists on the formula, this will be ran instead of ccpkg install
-- code, allowing custom installations
-- @param env the env that the script was executed from
-- @param ccpkg the ccpkg instance
-- @param artifacts the directory where the package artifacts are located
-- @param version the version of the package being installed
function package:install(env, ccpkg, artifacts, version)  -- [OPTIONAL] An installation hook. Allows custom logic for installation
    -- We move our script into the bin path so it's available globally
    env.fs.move(artifacts.."/say-hello.lua", "/ccpkg/bin/say-hello.lua")
end

-- TODO
-- This hook is called right after the package has been installed
function package:postInstall(version)  -- [OPTIONAL] A post install hook
    -- Do some stuff
end

-- This hook is called during the uninstallation of a package
-- code, allowing custom installations
-- @param env the env that the script was executed from
-- @param ccpkg the ccpkg instance
-- @param artifacts the directory where the package artifacts are located
-- @param version the version of the package being uninstalled
function package:uninstall(env, ccpkg, artifacts, version)  -- [OPTIONAL] An uninstallation hook. Allows custom logic for uninstallation
    -- We remove our script
    env.fs.delete("/ccpkg/bin/say-hello.lua")

end

return package  -- [REQUIRED] Always return your package table
```

### Properties

A breakdown of the properties present in the formulas table. Required fields are marked with an \*, optional fields are marked with an ?.

#### name (\*)

This is the name for your package. It _must_ be unique and it _must_ match the name of the formulas file. A recommended naming standard is either `alloneword` or `kebab-case`. This makes it easier to type your package name out.

#### description (\*)

This is a detailed description of what your package does. It is visible when you run `search` or `list` commands and it is also visible on the packages page on this website.

## Creating a Formula

First start off by forking the [ccpkg]({{ site.github.repository_url }}) respository.

Copy and paste the `ccpkg-hello-world` formula and rename the file to the name of your package. Then fill in the properties as you see fit.

### package:install

This hook is called once ccpkg has prepared your package for installation. There are two ways to install your package, and the one you choose depends on how your package is currently setup.

#### Running your own install script

If your package contains its own install script, great! You can save yourself some time and simply run:

```lua
env.shell.run(artifacts.."/path/to/your/install/script", "arg1", "arg2", "...")
```

#### Installing manually

So you don't have an install script? You can install your package right from this hook as if it _was an install script_.

You have full access to the CC `_ENV` table in the `env` parameter, and your package has been extrated to a tmp path represented by the `artifacts` parameter. In the example package, I simply move my single `say-hello` file to the `bin` folder managed by `ccpkg`. This makes my script available in the path!

```lua
function package:install(env, ccpkg, artifacts, version)  -- [OPTIONAL] An installation hook. Allows custom logic for installation
    -- We move our script into the bin path so it's available globally
    env.fs.move(artifacts.."/say-hello.lua", "/ccpkg/bin/say-hello.lua")
end
```

A more complicated example would be the [mbs]({{ "/formula/mbs" | absolute_url }}) package which involves moving files, creating directories and creating startup configuration.

```lua
function package:install(env, ccpkg, artifacts, version)
    local fs = env.fs
    fs.makeDir("/.mbs")
    fs.makeDir("/ccpkg/lib/mbs")
    fs.move(artifacts.."/bin", "/.mbs/bin")
    fs.move(artifacts.."/lib", "/.mbs/lib")
    fs.move(artifacts.."/modules", "/.mbs/modules")
    env.fs.move(artifacts.."/mbs.lua", "/ccpkg/lib/mbs/mbs.lua")

    local handle = fs.open("startup/00_mbs.lua", "w")
    handle.writeLine(("assert(loadfile('/ccpkg/lib/mbs/mbs.lua', _ENV))('startup', '/ccpkg/lib/mbs/mbs.lua')"))
    handle.close()
end
```

### package:uninstall

This hook is called when ccpkg is ran with the `remove` command. There are two ways to uninstall your package, and the one you choose depends on how your package is currently setup.

#### Running your own uninstall script

If your package contains its own uninstall script, great! You can save yourself some time and simply run:

```lua
env.shell.run(artifacts.."/path/to/your/uninstall/script", "arg1", "arg2", "...")
```

#### Removing manually

So you don't have an uninstall script? You can uninstall your package right from this hook as if it _was an uninstall script_.

You have full access to the CC `_ENV` table in the `env` parameter. In the example package, I simply delete my single `say-hello` file from the `bin` folder managed by `ccpkg`.

```lua
function package:uninstall(env, ccpkg, artifacts, version)  -- [OPTIONAL] An uninstallation hook. Allows custom logic for uninstallation
    -- We remove our script
    env.fs.delete("/ccpkg/bin/say-hello.lua")
end
```

A more complicated example would be the [mbs]({{ "/formula/mbs" | absolute_url }}) which has a more involed clean up process.

```lua
function package:uninstall(env, ccpkg, version)
    local fs = env.fs
    fs.delete("/.mbs")
    fs.delete("/startup/00_mbs.lua")
    fs.delete("/ccpkg/lib/mbs")
end
```

Once you are happy, you can create a PR for your formula that merges in the `main` branch. It will be reviewed and merged in, and your formula will be available to download and to view on the website.
