{stdenv, fetchurl, jre}:

stdenv.mkDerivation {
  name = "mendix-7.13.1";
  src = fetchurl {
    url = https://download.mendix.com/runtimes/mendix-7.13.1.tar.gz;
    sha256 = "1v620zmxm1s50p5jhpl74xvr0jv4j334cg1yfvy0mvgz4x0jrr7y";
  };
  installPhase = ''
    cd ..
    mkdir -p $out/libexec/mendix
    mv 7.13.1 $out/libexec/mendix

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
    export MX_INSTALL_PATH=$out/libexec/mendix/7.13.1
    ${jre}/bin/java -jar $out/libexec/mendix/7.13.1/runtime/launcher/runtimelauncher.jar "\$@"
    EOF
    chmod +x $out/bin/runtimelauncher
  '';
}
