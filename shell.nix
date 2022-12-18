{ pkgs, gems, ruby }:
stdenv.mkDerivation {
  name = "env";
  buildInputs = [
    ruby.devEnv
    bundix
    gems
  ];
}
