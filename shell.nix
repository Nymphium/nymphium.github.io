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
  LOCALE_ARCHIVE = lib.optionalString stdenv.isLinux "${glibcLocales}/lib/locale/locale-archive";
  LANG="en_US.UTF-8";
  shellHook = ''
    export PATH="''${PWD}/.bundle/ruby/${ruby.version.libDir}/bin":''${PATH}
    bundle config set --local path "''${PWD}/.bundle"
  '';
}
