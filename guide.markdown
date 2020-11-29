---
layout: default
---

# Guide
----

In this guide you will learn how to use ccpkg, as well as contribute a package to the repository.

{% include table-of-contents.html %}


### Commands
{: #commands}

#### Install a package
{: #commands_install}

```sh
ccpkg install <package-name>
```

#### Remove a package
{: #commands_remove}


```sh
ccpkg remove <package-name>
```

#### Search for a package
{: #commands_search}

```sh
ccpkg search <package-name>
```

#### List all packages
{: #commands_list}

Lists all the available packages. (This list could get pretty long, maybe install the [mbs]({{ "f/mbs" | relative_url }}) package to allow scrolling)

```sh
ccpkg list
```

## Contributing
{: #contrib}


Adding your own packages to the repository is easy. If you are familiar with Github forking and Pull Requests, you can get going in just a few minutes.

You will require knowledge of ComputerCraft, as each **formula** works by exposing an **install** and **uninstall** hook. These are called by `ccpkg` once your package has been extracted to an artifact directory.

### Formula
{: #contrib_formula}


The anatomy of a Formula file, comments explain each section, however I have also extracted out certain ones below for cover more details. This formula has been taken from the [ccpkh-hello-world]({{ "/f/ccpkg-hello-world" | absolute_url }}) formula:

```lua
 -- Replaced by script
```
{: #example-formula}

#### Properties
{: #contrib_formula_properties}

A breakdown of the properties present in the formulas table.

##### name
{: #contrib_formula_properties_name}

This is the name for your package. It _must_ be unique and it _must_ match the name of the formulas file. A recommended naming standard is either `alloneword` or `kebab-case`. This makes it easier to type your package name out.

##### description
{: #contrib_formula_properties_description}

This is a detailed description of what your package does. It is visible when you run `search` or `list` commands and it is also visible on the packages page on this website.

## Creating a Formula
{: #contrib_create}

First start off by forking the [ccpkg]({{ site.github.repository_url }}) respository.

Copy and paste the `ccpkg-hello-world` formula and rename the file to the name of your package. Then fill in the properties as you see fit.

### Folder structure
{: #contrib_create_fstruct}

#### /ccpkg/bin

ccpkg exposes a single directory, `/ccpkg/bin` to the system `path`, any files placed in here will be available from anywhere.
Putting your runnable files here will make easy to use without having to worry about setting up extra paths.
#### /ccpkg/lib

The library folder is a place to put non runnable dependencies that want to expose to other programs. If your
package is a pure API it should be placed here. You can also put your dependencies here, and reference them by module name and ccpkg will resolve them for you. This means you could have a single script in `/ccpkg/bin` and all your library files in `/ccpkg/lib/my_sexy_package/`, allowing for an easier clean up process


### package:install
{: #contrib_create_install}


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
{: #contrib_create_uninstall}


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

### Create PR
{: #contrib_create_pr}

Once you are happy, you can create a PR for your formula that merges in the `main` branch. It will be reviewed and then approved, and your formula will be available to use and view on the website.