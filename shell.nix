{ pkgs, ruby }:
with pkgs;
mkShell {
  buildInputs = [
    libffi
    pkgconfig
    ruby
  ];
  shellHook = ''
    export LANG="en_US.UTF-8"
    export PATH="''${PWD}/.bundle/ruby/${ruby.version.libDir}/bin":''${PATH}
    bundle config set --local path .bundle
  '';
}
