Pkg: ULua Package Manager
=========================

A simple but powerful package manager for the [ULua distribution](http://ulua.io).

## Features

- install, remove, list, query, update packages
- proxy (with auth) support

```lua
local pkg = require 'pkg'

pkg.available()            -- List all available packages.
pkg.available('?penlight') -- List available packages matching in name or description 'penlight'.
pkg.available('pl')        -- Detailed info about Penlight.

pkg.add('pl')              -- Install Penlight and its dependencies.
pkg.remove('pl')           -- Remove Penlight and all packages that depend on it.

pkg.update()               -- Update all packages.
```

## Upkg

An helper executable named `upkg` is included which replicates the functionality of this module.

```
upkg command [-s] [name] [version]
  command : one of "status", "available", "add", "remove", "update"
  -s      : enable searching (only for "status" and "available" commands)
  name    : package name
  version : package version
```

## Install

This module is included in the ULua distribution.

## Documentation

Refer to the [official documentation](http://ulua.io/pkg.html).