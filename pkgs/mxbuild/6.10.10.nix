{stdenv, fetchurl, mono, sqlite, nodejs-6_x, nodejs-8_x}:

stdenv.mkDerivation {
  name = "mxbuild-6.10.10";
  src = fetchurl {
    url = https://download.mendix.com/runtimes/mxbuild-6.10.10.tar.gz;
    sha256 = "1jny40rifqkcxb83fp8v76pk5lc6nsxs5ax1cvlisnyllskka7d6";
  };
  unpackPhase = ''
    mkdir mxbuild
    cd mxbuild
    unpackFile $src
  '';
  mendixVersion = "6.10.10";
  installPhase = ''
    mkdir -p $out/libexec/mxbuild/$mendixVersion
    mv modeler runtime $out/libexec/mxbuild/$mendixVersion

    # Replace embedded Node.js 0.12.x by a version provided by Nixpkgs
    rm $out/libexec/mxbuild/$mendixVersion/modeler/tools/grunt/node
    ln -s ${nodejs-6_x}/bin/node $out/libexec/mxbuild/$mendixVersion/modeler/tools/grunt/node

    # Replace embedded Node.js 8.x by a version provided by Nixpkgs
    #rm $out/libexec/mxbuild/$mendixVersion/modeler/tools/node/node
    #ln -s ${nodejs-8_x}/bin/node $out/libexec/mxbuild/$mendixVersion/modeler/tools/node/node

    # Create wrapper script to invoke mxbuild
    mkdir -p $out/bin

    cat > $out/bin/mxbuild <<EOF
    #! ${stdenv.shell} -e
    export LD_LIBRARY_PATH=${sqlite.out}/lib
    ${mono}/bin/mono $out/libexec/mxbuild/$mendixVersion/modeler/mxbuild.exe "\$@"
    EOF
    chmod +x $out/bin/mxbuild
  '';
}
