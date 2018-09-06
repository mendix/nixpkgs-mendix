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
    };

    packageMendixApp = callPackage ../build-support/package-mendix-app { };

    runMendixApp = callPackage ../build-support/run-mendix-app { };
  };
in
self
