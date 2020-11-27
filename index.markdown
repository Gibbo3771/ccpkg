---
layout: default
---

**ccpkg** is a package manager specifically created for ComputerCraft (CC) that allows a centralized distribution source for vetted libaries, programs and command-line tools. Anyone can contiribute to the central repository, and anyone can explore and use it.
{: .text--center .padding-top--4}

## Get started

### Installation

```sh
wget run https://raw.githubusercontent.com/Gibbo3771/ccpkg/main/install.lua
```

Get started by [browsing the package repository]({{ "/formula" | absolute_url }}) or install the [example package]({{ site.baseurl }}{{ "f_ccpkg-hello-world" | datapage_url: "" }})

## Features

- Add and remove packages using formula definitions
- Package versioning
- Startup configuration to autoload paths
- Package caching
- List and search commands
- Colored output and extensive logging

## Commands

#### Installing a package

```sh
ccpkg install <package-name>
```

#### Removing a package

```sh
ccpkg remove <package-name>
```

#### Search for a package by name

```sh
ccpkg search <package-name>
```

#### List all packages

Lists all the available packages. (This list could get pretty long, maybe install the [mbs]({{ site.baseurl }}{{ "f_mbs" | datapage_url: "" }}) package to allow scrolling)

```sh
ccpkg list
```

## Contributing

Got a package you want to add? Head over to the [documentation]({{ "/contributing" | relative_url }}) to learn how.
