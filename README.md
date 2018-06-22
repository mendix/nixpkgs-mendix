nixpkgs-mendix
==============
Repository of [Mendix](http://mendix.com) packages that can be deployed by
using the [Nix package manager](http://nixos.org/nix) and related technologies.

It currently offers the following features:
* Various versions of the Mendix runtime and `mxbuild` as Nix packages
* A Nix function that can be used to compile Mendix Deployment Archives (MDA)
  from Mendix projects
* A module for [NixOS](http://nixos.org) that can be used to launch an app
  container.

The content of this repository is EXPERIMENTAL -- it is not as feature complete
and well tested as the other integrated solutions, such as
[m2ee-tools](https://github.com/mendix/m2ee-tools) and the
[CloudFoundry build pack](https://github.com/mendix/cf-mendix-buildpack).

Prerequisites
=============
* The Nix package manager
* When it is desired to deploy an entire machine declaratively: NixOS

Usage
=====
This package provides a number of use cases.

Deploying the Mendix runtime
----------------------------
This repository provides various versions of the Mendix runtime that can be
deployed as follows:

```bash
$ nix-build top-level/all-packages.nix -A 'mendix."7.13.1"'
```

In addition, the runtime package provides a script that can be used to launch
the runtime:

```bash
$ ./result/bin/runtimelauncher
```

Deploying mxbuild
-----------------
In addition to the runtime, also various versions of the `mxbuild` tool are
provided:

```bash
$ nix-build top-level/all-packages.nix -A 'mxbuild."7.13.1"'
$ ./result/bin/mxbuild
```

Building an MDA file from a project
-----------------------------------
In addition to the Mendix packages, we can also use a Nix function abstraction
to compile an MDA file from a Mendix project:

```nix
{ pkgs ? import <nixpkgs> { inherit system; }
, system ? builtins.currentSystem
}:

let
  mendixPkgs = import ../nixpkgs-mendix/top-level/all-packages.nix {
    inherit pkgs system;
  };
in
mendixPkgs.packageMendixApp {
  name = "mymendixapp";
  src = /home/sbu/SharedWindowsFolder/MyMendixApp-main;
  mendixVersion = "7.13.1";
}
```

The above expression can be used, for example, to use
[Hydra](http://nixos.org/hydra) as a continious integration service from Mendix
projects.

Adding an app container instance to a NixOS configuration
---------------------------------------------------------
This package also offers a NixOS module that automatically launches a running
app container:

``nix
{pkgs, ...}:

{
  require = [ ../nixpkgs-mendix/nixos/modules/mendixappcontainer.nix ];

  services.mendixAppContainer = {
    enable = true;
    adminPassword = "secret";
    databaseType = "HSQLDB";
    databaseName = "myappdb";
    DTAPMode = "D";
    app = import ./mymendixapp.nix {
      inherit pkgs;
      inherit (pkgs.stdenv) system;
    };
  };

  networking.firewall.allowedTCPPorts = [ 8080 ];
}
```

After deploying a NixOS configuration with the app container enabled, you
should be able to open a web browser and connect to the machine on TCP port
8080.

Consult the code of the NixOS module to see all the configuration options that
are supported.

Mendix versions supported
=========================
Currently, only two Mendix runtime versions are supported:

* 6.10.10
* 7.13.1

License
=======
The functionality provided by this package can be used under the terms and
conditions of the Apache Software License version 2.0.
