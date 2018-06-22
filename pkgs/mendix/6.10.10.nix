{stdenv, fetchurl, jre}:

stdenv.mkDerivation {
  name = "mendix-6.10.10";
  src = fetchurl {
    url = https://download.mendix.com/runtimes/mendix-6.10.10.tar.gz;
    sha256 = "1lil0j1gf9v8g6z6a2z69airfygj8r2bg75pw3xkfjybncfab4dc";
  };
  installPhase = ''
    cd ..
    mkdir -p $out/libexec/mendix
    mv 6.10.10 $out/libexec/mendix

    mkdir -p $out/bin

    # Create script that creates additional state directories
    cat > $out/bin/init-app-state <<EOF
    #! ${stdenv.shell} -e
    sed -e "s|{ProjectBundlesDir}|\$1/model/bundles|g" \
      -e "s|{InstallDir}|$out/libexec/mendix/6.10.10|g" \
      -e "s|{FrameworkStorage}|\$1/data/tmp/felixcache|g" \
      $out/libexec/mendix/6.10.10/runtime/felixconfig.properties.template > \$1/model/felixconfig.properties

    mkdir -p \$1/data/tmp/felixcache
    mkdir -p \$1/data/database
    mkdir -p \$1/data/files
    EOF
    chmod +x $out/bin/init-app-state

    # Create wrapper script for the runtime launcher
    cat > $out/bin/runtimelauncher <<EOF
    #! ${stdenv.shell} -e
    ${jre}/bin/java -classpath $out/libexec/mendix/6.10.10/runtime/felix/bin/felix.jar -Djava.io.tmpdir=\$1/data/tmp -Dfelix.config.properties=file:\$1/model/felixconfig.properties org.apache.felix.main.Main
    EOF
    chmod +x $out/bin/runtimelauncher
  '';
}
