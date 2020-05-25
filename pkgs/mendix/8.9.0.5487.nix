{stdenv, fetchurl, jre}:

stdenv.mkDerivation {
  name = "mendix-8.9.0.5487";
  src = fetchurl {
    url = https://download.mendix.com/runtimes/mendix-8.9.0.5487.tar.gz;
    sha256 = "06k4agabfk1jh8c2gw9x3q46nvyx1xk7idf3wa0x2spa33n1y02m";
  };
  installPhase = ''
    cd ..
    mkdir -p $out/libexec/mendix
    mv 8.9.0.5487 $out/libexec/mendix

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
    export MX_INSTALL_PATH=$out/libexec/mendix/8.9.0.5487
    ${jre}/bin/java -jar $out/libexec/mendix/8.9.0.5487/runtime/launcher/runtimelauncher.jar "\$@"
    EOF
    chmod +x $out/bin/runtimelauncher
  '';
}
