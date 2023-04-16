{ pkgs, ruby, rubyPkgs }:
with pkgs;
let
  solargraph = rubyPkgs.solargraph;
in
mkShell {
  buildInputs = [
    libffi
    libsass
    pkgconfig
    ruby
    solargraph
  ];
  shellHook = ''
    export LANG="en_US.UTF-8"
    export PATH="''${PWD}/.bundle/ruby/${ruby.version.libDir}/bin":''${PATH}
    bundle config set --local path "''${PWD}/.bundle"
  '';
}
