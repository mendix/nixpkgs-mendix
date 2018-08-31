{stdenv, curl, unzip, nodejs, netcat, mendix}:
{app, mendixVersion ? null, ...}@args:

let
  selectedMendixVersion = if mendixVersion == null then app.mendixVersion else mendixVersion;
  mendixPkg = mendix."${selectedMendixVersion}";
  curlCmd = ''${curl}/bin/curl -X POST http://localhost:\$M2EE_ADMIN_PORT -H 'Content-Type: application/json' -H "X-M2EE-Authentication: \$authvalue" -H 'Connection: close' '';
  extraArgs = builtins.removeAttrs args [ "app" ];
in
stdenv.mkDerivation ({
  name = "run-mendix-app${if builtins.isAttrs app then "-${app.name}" else ""}";
  buildCommand = ''
    mkdir -p $out/bin
    cat > $out/bin/start-appcontainer <<EOF
    #! ${stdenv.shell} -e

    # Unpack the app in a state directory
    MENDIX_STATE_DIR=\''${MENDIX_STATE_DIR:-\$HOME/mendixappcontainer}
    mkdir -p "\$MENDIX_STATE_DIR"

    if [ -d "${app}" ]
    then
        ${unzip}/bin/unzip -o ${app}/*.mda -d "\$MENDIX_STATE_DIR"
    else
        ${unzip}/bin/unzip -o ${app} -d "\$MENDIX_STATE_DIR"
    fi

    ${mendixPkg}/bin/init-app-state "\$MENDIX_STATE_DIR"
    ${mendixPkg}/bin/runtimelauncher "\$MENDIX_STATE_DIR"
    EOF
    chmod +x $out/bin/start-appcontainer

    cat > $out/bin/configure-appcontainer <<EOF
    #! ${stdenv.shell} -e
    MENDIX_STATE_DIR=\''${MENDIX_STATE_DIR:-\$HOME/mendixappcontainer}
    authvalue=\$(echo -n "\$M2EE_ADMIN_PASS" | base64)

    # Wait for the admin port to become available
    while ! ${netcat}/bin/nc -z localhost \$M2EE_ADMIN_PORT
    do
        echo "Waiting for the admin interface to become available..." >&2
        sleep 1
    done

    # Configure the running app instance to actually run
    ${nodejs}/bin/node ${./composeappcontaineraction.js} "\$1" | ${curlCmd} -d @-
    ${nodejs}/bin/node ${./composeconfigurationaction.js} "\$2" "\$MENDIX_STATE_DIR" "$(echo ${mendixPkg}/libexec/mendix/*/runtime)" | ${curlCmd} -d @-
    ${curlCmd} -d '{ "action": "start" }'
    ${curlCmd} -d '{ "action": "execute_ddl_commands" }'
    ${curlCmd} -d '{ "action": "start" }'
    EOF
    chmod +x $out/bin/configure-appcontainer

    cat > $out/bin/undeploy-app <<EOF
    #! ${stdenv.shell} -e
    MENDIX_STATE_DIR=\''${MENDIX_STATE_DIR:-\$HOME/mendixappcontainer}

    find "\$MENDIX_STATE_DIR" -maxdepth 1 -mindepth 1 -type d -not -name data | while read i
    do
        rm -rf "\$i"
    done
    EOF
    chmod +x $out/bin/undeploy-app
  '';
} // extraArgs)
