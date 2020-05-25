{stdenv, fetchurl, mono, sqlite, nodejs-12_x}:

stdenv.mkDerivation {
  name = "mxbuild-8.9.0.5487";
  src = fetchurl {
    url = https://download.mendix.com/runtimes/mxbuild-8.9.0.5487.tar.gz;
    sha256 = "15pmww436rq4bwckxgxcwrngw8n3i71r3ldb20dy0mb258ga05jc";
  };
  unpackPhase = ''
    mkdir mxbuild
    cd mxbuild
    unpackFile $src
  '';
  mendixVersion = "8.9.0.5487";
  installPhase = ''
    mkdir -p $out/libexec/mxbuild/$mendixVersion
    mv modeler runtime $out/libexec/mxbuild/$mendixVersion

    # Replace embedded Node.js 8.x by a version provided by Nixpkgs
    rm $out/libexec/mxbuild/$mendixVersion/modeler/tools/node/node
    ln -s ${nodejs-12_x}/bin/node $out/libexec/mxbuild/$mendixVersion/modeler/tools/node/node

    # Create wrapper script to invoke mxbuild
    mkdir -p $out/bin

    cat > $out/bin/mxbuild <<EOF
    #! ${stdenv.shell} -e
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:''${LD_LIBRARY_PATH:+:}${sqlite.out}/lib
    ${mono}/bin/mono $out/libexec/mxbuild/$mendixVersion/modeler/mxbuild.exe "\$@"
    EOF
    chmod +x $out/bin/mxbuild
  '';
}
