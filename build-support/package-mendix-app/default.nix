{stdenv, mxbuild, jdk, nodejs}:
{name, mendixVersion, looseVersionCheck ? false, buildInputs ? [], ...}@args:

let
  mxbuildPkg = mxbuild."${mendixVersion}";
  extraArgs = removeAttrs args [ "buildInputs" ];
in
stdenv.mkDerivation ({
  buildInputs = [ mxbuildPkg nodejs ] ++ buildInputs;
  installPhase = ''
    mkdir -p $out
    mxbuild --target=package --output=$out/${name}.mda --java-home ${jdk} --java-exe-path ${jdk}/bin/java ${stdenv.lib.optionalString looseVersionCheck "--loose-version-check"} "$(echo *.mpr)"
    mkdir -p $out/nix-support
    echo "file binary-dist \"$(echo $out/*.mda)\"" > $out/nix-support/hydra-build-products
  '';
} // extraArgs)
