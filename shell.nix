{ pkgs, ruby }:
with pkgs;
mkShell {
  buildInputs = [
    libffi
    libsass
    pkgconfig
    ruby
  ];
  shellHook = ''
    export LANG="en_US.UTF-8"
    export PATH="''${PWD}/.bundle/ruby/${ruby.version.libDir}/bin":''${PATH}
    bundle config set --local path "''${PWD}/.bundle"
  '';
}
