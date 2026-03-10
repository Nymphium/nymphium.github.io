{
  pkgs,
  stdenv,
}:
let
  playwright-browsers = pkgs.playwright-driver.browsers;
  node = pkgs.nodejs;

  fonts = pkgs.symlinkJoin {
    name = "visual-test-fonts";
    paths = [ pkgs.noto-fonts-cjk-sans ];
  };

  fontconfig-conf = pkgs.makeFontsConf { fontDirectories = [ fonts ]; };
in
stdenv.mkDerivation {
  name = "visual-test";

  src = ../test/visual;

  nativeBuildInputs = [
    node
    pkgs.makeWrapper
  ];

  buildInputs = [
    pkgs.imagemagick
    pkgs.optipng
  ];

  installPhase = ''
    mkdir -p $out/bin $out/lib/visual-test $out/lib/node_modules

    cp $src/screenshots.mjs $out/lib/visual-test/
    cp $src/optimize.mjs $out/lib/visual-test/
    cp $src/compare.sh $out/lib/visual-test/
    chmod +x $out/lib/visual-test/compare.sh

    # Symlink playwright-core from the Nix store so `import "playwright-core"` resolves
    ln -s ${pkgs.playwright-driver} $out/lib/node_modules/playwright-core

    makeWrapper ${node}/bin/node $out/bin/visual-screenshots \
      --set PLAYWRIGHT_BROWSERS_PATH ${playwright-browsers} \
      --set PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS true \
      --set FONTCONFIG_FILE ${fontconfig-conf} \
      --prefix NODE_PATH : $out/lib/node_modules \
      --add-flags $out/lib/visual-test/screenshots.mjs

    makeWrapper ${node}/bin/node $out/bin/visual-optimize \
      --add-flags $out/lib/visual-test/optimize.mjs \
      --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.optipng ]}

    makeWrapper $out/lib/visual-test/compare.sh $out/bin/visual-compare \
      --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.imagemagick ]}
  '';

}
