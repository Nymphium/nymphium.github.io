{
  pkgs,
  ruby,
  rubyPkgs,
}:
with pkgs;
let
  solargraph = rubyPkgs.solargraph;
in
mkShell {
  buildInputs = [
    ruby
    solargraph
    pkg-config
    zlib
    libffi
    libsass
    protobuf
    libxml2
    libxslt
    nil
    nixfmt-rfc-style
  ];
  LOCALE_ARCHIVE = lib.optionalString stdenv.isLinux "${glibcLocales}/lib/locale/locale-archive";
  LANG = "en_US.UTF-8";
  shellHook = ''
    export PATH="''${PWD}/.bundle/ruby/${ruby.version.libDir}/bin":''${PATH}
    bundle config set --local path "''${PWD}/.bundle"
  '';
}
