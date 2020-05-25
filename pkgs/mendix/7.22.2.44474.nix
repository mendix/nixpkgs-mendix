{stdenv, fetchurl, jre}:

stdenv.mkDerivation {
  name = "mendix-7.22.2.44474";
  src = fetchurl {
    url = https://download.mendix.com/runtimes/mendix-7.22.2.44474.tar.gz;
    sha256 = "c2cf03436a48177ad23ee17f41196bdb3936cd872b238d9b188ff5efb68ac89d";
  };
  installPhase = ''
    cd ..
    mkdir -p $out/libexec/mendix
    mv 7.22.2.44474 $out/libexec/mendix

    mkdir -p $out/bin

    # Create script that creates additional state directories
    cat > $out/bin/init-app-state <<EOF
    #! ${stdenv.shell} -e
    mkdir -p \$1/data/files
    EOF
    chmod +x $out/bin/init-app-state

    # Create wrapper script for the runtime launcher
    cat > $out/bin/runtimelauncher <<EOF
    #! ${stdenv.shell} -e
    export MX_INSTALL_PATH=$out/libexec/mendix/7.22.2.44474
    ${jre}/bin/java -jar $out/libexec/mendix/7.22.2.44474/runtime/launcher/runtimelauncher.jar "\$@"
    EOF
    chmod +x $out/bin/runtimelauncher
  '';
}
