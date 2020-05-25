{ pkgs ? import <nixpkgs> { inherit system; }
, system ? builtins.currentSystem
}:

let
  callPackage = pkgs.lib.callPackageWith (pkgs // self);

  self = rec {
    mendix = {
      "6.10.10" = callPackage ../pkgs/mendix/6.10.10.nix { };
      "7.13.1" = callPackage ../pkgs/mendix/7.13.1.nix { };
      "7.17.2" = callPackage ../pkgs/mendix/7.17.2.nix { };
      "7.20.0.41900" = callPackage ../pkgs/mendix/7.20.0.41900.nix { };
      "7.22.2.44474" = callPackage ../pkgs/mendix/7.22.2.44474.nix { };
      "8.9.0.5487" = callPackage ../pkgs/mendix/8.9.0.5487.nix {
        jre = pkgs.openjdk11;
      };
    };

    mxbuild = {
      "6.10.10" = callPackage ../pkgs/mxbuild/6.10.10.nix {
        mono = pkgs.mono44;
      };
      "7.13.1" = callPackage ../pkgs/mxbuild/7.13.1.nix {
        mono = pkgs.mono46;
      };
      "7.17.2" = callPackage ../pkgs/mxbuild/7.17.2.nix {
        mono = pkgs.mono46;
      };
      "7.20.0.41900" = callPackage ../pkgs/mxbuild/7.20.0.41900.nix {
        mono = pkgs.mono46;
      };
      "7.22.2.44474" = callPackage ../pkgs/mxbuild/7.22.2.44474.nix {
        mono = pkgs.mono46;
      };
      "8.9.0.5487" = callPackage ../pkgs/mxbuild/8.9.0.5487.nix {
        mono = pkgs.mono5;
      };
    };

    packageMendixApp = callPackage ../build-support/package-mendix-app { };

    runMendixApp = callPackage ../build-support/run-mendix-app { };
  };
in
self
