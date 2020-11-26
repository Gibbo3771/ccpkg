# ccpkg - a Computer Craft powered package manager


An early work in progress for a package manager specifically for Computer Craft (CC).

ccpkg will allow CC programmers distribute their programs and avoid issues that come with pastebin, such as versioning and permanent urls. Manage each version through the central "repository" (lives [here](https://github.com/Gibbo3771/ccpkg/tree/main/formula)) using lua scripts, add, remove and update packages on the fly.


## Features
Features are being put in quite frequently, so far we support the following operations:

* Add and remove packages using formula definitions
* Package versioning (no auto diffing)
* Startup configuration to autoload paths
* Package caching
* Colored output and extensive logging

&nbsp;


## Planned features

There is quite a few things missing that I want to get around to doing.

* Pre and Post installation hooks
* Resolve dependencies
* Additional fields in formula such as liscence, email, contributors etc
* Master list maintained via CI
* Query said master list to provide autocomplete functions 

&nbsp;

## Installation

Download the installation script by pasting the following command into your computer:
`wget run https://raw.githubusercontent.com/Gibbo3771/ccpkg/main/install.lua`



### Example

You can see an example by following the commands below:
```sh
ccpkg install ccpkg-hello-world
```
Once installation is complete, you can run `say-hello` from your terminal

&nbsp;


### Commands
Below is the list of commands you can run:

`ccpkg remove <package-name>` - Remove a package

`ccpkg install <package-name>` - Installs a package

`ccpkg search <package-name>` - Search for a package by name


That's pretty much it.

&nbsp;


### Formula

The anatomy of a Formula file, comments explain each section. This formula has been taken from the `ccpkh-hello-world` formula:

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

&nbsp;


### Creating a Formula

First off, fork this repository. Direct commits are not permitted.

Follow the above anatomy to create your formula properly. Here are criteria each package must meet:
* The file name **must** match the package name
* Either join each word in the file/pakage name or use kebab case
* Your package and file name must be unique
* Your packages **must** be downloadable as a `.tar.gz`

Once you are happy, create a PR with your Formula. If you are keeping your packages up to date and are active, you will be given the ability to merge your own PR.

&nbsp;


### Caveats

Lots. There is some modification of `package.path` and what not, and I am not sure on the side effects or weirdness you will get with my implementation of the path resolution. I didn't realise `shell.resolve` was a thing!

My only package sucks.

&nbsp;


## NOTE

I still have to give credit where credit is due, thanks to [CC-Tweaked](https://github.com/Gibbo3771/CC-Tweaked) for keeping the CC mod alive in newer versions and thanks to [CC-Arhive](https://github.com/MCJack123/CC-Archive) for the gzip/tar implementation. I will put this in a proper blurb soon.



