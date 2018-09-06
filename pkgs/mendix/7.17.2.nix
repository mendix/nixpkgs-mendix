{stdenv, fetchurl, jre}:

stdenv.mkDerivation {
  name = "mendix-7.17.2";
  src = fetchurl {
    url = https://download.mendix.com/runtimes/mendix-7.17.2.tar.gz;
    sha256 = "0qjvmjbqv71yqc5iq2idw3wjwfk6m74iqmf0limms2gb937g35bf";
  };
  installPhase = ''
    cd ..
    mkdir -p $out/libexec/mendix
    mv 7.17.2 $out/libexec/mendix

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
    export MX_INSTALL_PATH=$out/libexec/mendix/7.17.2
    ${jre}/bin/java -jar $out/libexec/mendix/7.17.2/runtime/launcher/runtimelauncher.jar "\$@"
    EOF
    chmod +x $out/bin/runtimelauncher
  '';
}
