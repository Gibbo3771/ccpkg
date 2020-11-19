# ccpkg - a Computer Craft powered package manager


An early work in progress for a lua package manager specifically for Computer Craft (CC).

ccpkg will allow CC programmers to come together and share common code without having the problems associated with pastebin. Manage each version through the central "repository" (lives [here](https://github.com/Gibbo3771/ccpkg/tree/main/formula)) using lua scripts, add, remove and update packages on the fly.

&nbsp;


## Features
Features are being put in quite frequently, so far we support the following operations:

* Add and remove packages from formula definitions
* Local and global dependencies
* Package versioning (no auto diffing)
* Create projects for locally scoped dependencies
* Priority dependency resolution (checks local before global)
* Startup configuration to autoload paths, with optional bootstrapped startup file per project
* Built in `run` command to execute non project scripts with ccpkg module resolution
* Package caching
* Colored output and extensive logging

&nbsp;


## Planned features

There is quite a few things missing that I want to get around to doing.

* Pre and Post installation hooks
* Resolve dependencies of dependencies if they are ccpkg projects
* .gitignore tempate
* "binary" installation method to allow execution of entire programs (think entire turtle programs)
* Additional fields in formula such as liscence, email, contributors etc
* Master list maintained via CI
* Query said master list to provide autocomplete functions 

&nbsp;

## Installation

Download the installation script by pasting the following command into your computer:
`wget run https://raw.githubusercontent.com/Gibbo3771/ccpkg/main/install.lua`

Once downloaded, run `install`. When asked to enable **global** packages, say yes. You can read more about global packages below. You're then all set!

### Example

You can see an example by creating a new project by running the following commands:
```
mkdir example
cd example
ccpkg new example
ccpkg add ccpkg-hello-world
edit init
```
Inside the `init` file, enter the following code below the existing code):

```lua
local h = require("ccpkg-hello-world.hello")
h:hello()
```
Test it by running `init`.

To add it to your startup, you can just require your project directly, like so:

```lua
require("example.init")
```

&nbsp;


### Commands
Below is the list of commands you can run:

`ccpkg new <project-name>` - Create a new project with the given name (*this does not create a folder!*)

`ccpkg add <package-name>` - Add a package to your project as a dependency

`ccpkg remove <package-name>` - Remove a package

`ccpkg run <file>` - Runs a script using the ccpkg environment

`ccpkg install` - Installs all the dependencies specified in the `pkg.json`

That's pretty much it.

&nbsp;


### Global packages

As well as installing packages locally on a per project basis, you can also
install them **globally**. This is most useful when you want to include entire programs
in all your projects, or if you simply want to install a program and run it from
your start file without having to create a project using `new`.

To use **global** packages, you can include the `global` sub command.

Adding a package:

`ccpkg add global <package-name>`

Removing a package:

`ccpkg remove global <package-name>`

&nbsp;


### Formula

The anatomy of a Formula file, comments explain each section

```lua
local helloWorld = { -- [REQUIRED] Specify your formula as a table
    name = "ccpkg-hello-world", -- [REQUIRED] The name of your package, this should match your filename
    description = "This is an example formula",  -- The description of your package
    versions = { --[REQUIRED] A list of versions, each key is the version number and the value is the url to the tarbal
        ["2.0.0"] = "https://github.com/Gibbo3771/ccpkg-hello-world/archive/2.0.0.tar.gz",
        ["1.0.0"] = "https://github.com/Gibbo3771/ccpkg-hello-world/archive/1.0.0.tar.gz"
    }
}

function helloWorld:stable() -- [REQUIRED] Species the stable version of your package
   return "2.0.0"
end

-- NOT IMPLEMENTED
-- This hook is called right after the package has been installed
function helloWorld:postInstall(version)
    -- Do some stuff
end

-- NOT IMPLEMENTED
-- This hook is called right before the package is installed
function helloWorld:preInstall(version)
    -- Do some stuff
end

return helloWorld -- [REQUIRED] Return it so ccpkg can compile and run it
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


