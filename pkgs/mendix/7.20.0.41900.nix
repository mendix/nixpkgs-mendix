{stdenv, fetchurl, jre}:

stdenv.mkDerivation {
  name = "mendix-7.20.0.41900";
  src = fetchurl {
    url = https://download.mendix.com/runtimes/mendix-7.20.0.41900.tar.gz;
    sha256 = "8a8caa6f790d986ca458b2346292baa8380ec5919fd940378f625406807f9b12";
  };
  installPhase = ''
    cd ..
    mkdir -p $out/libexec/mendix
    mv 7.20.0.41900 $out/libexec/mendix

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
    export MX_INSTALL_PATH=$out/libexec/mendix/7.20.0.41900
    ${jre}/bin/java -jar $out/libexec/mendix/7.20.0.41900/runtime/launcher/runtimelauncher.jar "\$@"
    EOF
    chmod +x $out/bin/runtimelauncher
  '';
}
