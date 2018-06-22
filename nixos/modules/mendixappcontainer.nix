{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.mendixAppContainer;

  mendixPkgs = import ../../top-level/all-packages.nix {
    inherit pkgs;
    inherit (pkgs.stdenv) system;
  };
in
{
  options = {
    services.mendixAppContainer = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Whether to enable the Mendix app container.";
      };

      adminPort = mkOption {
        type = types.int;
        default = 9000;
        description = "TCP port where the admin interface listens to.";
      };

      adminPassword = mkOption {
        type = types.string;
        default = "Password1!";
        description = "Password required to communicate with the admin interface.";
      };

      runtimePort = mkOption {
        type = types.int;
        default = 8080;
        description = "TCP port where the embedded Jetty HTTP server listens to.";
      };

      runtimeJettyOptions = mkOption {
        type = types.listOf types.string;
        default = [];
        description = "Array of additional Jetty options.";
      };

      runtimeListenAddresses = mkOption {
        type = types.string;
        default = "0.0.0.0";
        description = "IP addresses where the embedded Jetty HTTP server binds to.";
      };

      databaseType = mkOption {
        type = types.string;
        default = "HSQLDB";
        description = "Type of database to use for storage. Possible options are 'HSQLDB' (the default) or 'PostgreSQL'";
      };

      databaseName = mkOption {
        type = types.string;
        description = "Name of the database that stores all persistent data records.";
      };

      databaseUsername = mkOption {
        type = types.string;
        description = "Username of the user that has write access to the database.";
      };

      databasePassword = mkOption {
        type = types.string;
        description = "Password of the user that has write access to the database.";
      };

      DTAPMode = mkOption {
        type = types.string;
        default = "P";
        description = "Specifies the security-level of the running app. Possible values are: 'D' (Development), 'T' (Test), 'A' (Acceptance), 'P' (Production).";
      };

      app = mkOption {
        type = types.package;
        description = "Mendix MDA to deploy";
      };

      stateDir = mkOption {
        type = types.string;
        default = "/home/mendix";
        description = "Location where the app's state files are stored.";
      };

      mendixVersion = mkOption {
        type = types.string;
        default = null;
        description = "Specifies the version of the Mendix runtime to use. When set to null, the used version is identical to the mxbuild version used to compile the MDA.";
      };
    };
  };

  config = mkIf cfg.enable {
    users = {
      groups = {
        mendix = { gid = 400; };
      };

      users = {
        mendix = { createHome = true; description = "Mendix"; group = "users"; home = "/home/mendix"; shell = "/bin/sh"; uid = 400; };
      };
    };

    systemd.services.mendixappcontainer =
      let
        appContainerConfigJSON = pkgs.writeTextFile {
          name = "appcontainer.json";
          text = builtins.toJSON {
            runtime_port = cfg.runtimePort;
            runtime_listen_addresses = cfg.runtimeListenAddresses;
            runtime_jetty_options = cfg.runtimeJettyOptions;
          };
        };

        configJSON = pkgs.writeTextFile {
          name = "config.json";
          text = builtins.toJSON ({
            DatabaseType = cfg.databaseType;
            DatabaseName = cfg.databaseName;
            DTAPMode = cfg.DTAPMode;
          } // lib.optionalAttrs (cfg.databaseType == "PostgreSQL") {
            DatabaseHost = "127.0.0.1:${toString config.services.postgresql.port}";
            DatabaseUserName = cfg.databaseUsername;
            DatabasePassword = cfg.databasePassword;
          });
        };

        runScripts = mendixPkgs.runMendixApp {
          inherit (cfg) app;
        };
      in
      {
        enable = true;
        description = "My Mendix App";
        wantedBy = [ "multi-user.target" ];
        after = lib.optional (config.services.postgresql.enable) "postgresql.service";

        environment = {
          M2EE_ADMIN_PASS = cfg.adminPassword;
          M2EE_ADMIN_PORT = toString cfg.adminPort;
          MENDIX_STATE_DIR = cfg.stateDir;
        };

        serviceConfig = {
          User = "mendix";
          Group = "mendix";
          ExecStartPre = "${runScripts}/bin/undeploy-app";
          ExecStart = "${runScripts}/bin/start-appcontainer";
          ExecStartPost = "${runScripts}/bin/configure-appcontainer ${appContainerConfigJSON} ${configJSON}";
        };
      };
  };
}
