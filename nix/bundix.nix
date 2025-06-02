{
  pkgs,
  ruby,
  stdenvNoCC,
  lib,
  bundix,
}:
let
  bundix' = pkgs.callPackage bundix {
    inherit ruby;
  };
  drv = stdenvNoCC.mkDerivation {
    name = "patched-bundix";
    src = builtins.filterSource (
      path: type:
      (lib.any (suffix: lib.hasSuffix suffix path) [
        "Gemfile"
        "Gemfile.lock"
      ])
    ) ../.;

    buildInputs = with pkgs; [ makeWrapper ];

    buildPhase = "true";

    installPhase = ''
      mkdir -p $out/bin
      cp Gemfile{,.lock} $out
      makeWrapper ${bundix'}/bin/bundix $out/bin/patched-bundix \
        --append-flags "--ruby=${ruby}/bin/ruby" \
        --append-flags "--gemfile=$out/Gemfile" \
        --append-flags "--lockfile=$out/Gemfile.lock"
    '';

    passthru.app = {
      type = "app";
      program = drv + "/bin/patched-bundix";
    };
  };
in
drv
