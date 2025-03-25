{
  pkgs,
  stdenv,
  buildNpmPackage,
  importNpmLock,
  fetchFromGitHub,
}:
let
  pname = "BackStopJS";
  # 6.3.25
  version = "930b3c863d3946fd3c8156166692739479ad51c7";
  src = fetchFromGitHub {
    owner = "garris";
    repo = pname;
    hash = "sha256-bAIGBKemWmkbqzxd4L4CFKslfjn1mwgTBpymiuJCxYo=";
    rev = version;
  };

  playwright = stdenv.mkDerivation {
    name = "${pname}-playwright";

    nativeBuildInputs = [
      pkgs.nodejs
      pkgs.playwright
    ];

    buildInputs = [ pkgs.makeWrapper ];

    phases = [ "installPhase" ];

    installPhase = ''
      mkdir -p $out/bin
      makeWrapper ${drv}/bin/backstop $out/bin/backstop-playwright \
        --set PLAYWRIGHT_BROWSERS_PATH ${pkgs.playwright-driver.browsers} \
        --set PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS true
    '';

    passthru.app = {
      type = "app";
      program = playwright + "/bin/backstop-playwright";
    };
  };

  puppeteer = stdenv.mkDerivation {
    name = "${pname}-puppeteer";

    nativeBuildInputs = [
      pkgs.nodejs
    ];

    buildInputs = [ pkgs.makeWrapper ];

    phases = [ "installPhase" ];

    installPhase = ''
      mkdir -p $out/bin
      makeWrapper ${drv}/bin/backstop $out/bin/backstop-puppeteer \
        --set PUPPETEER_EXECUTABLE_PATH ${pkgs.google-chrome}/bin/google-chrome-stable
    '';

    passthru.app = {
      type = "app";
      program = puppeteer + "/bin/backstop-puppeteer";
    };
  };

  drv = buildNpmPackage {
    inherit pname version src;

    npmDeps = importNpmLock {
      npmRoot = src;
    };

    npmConfigHook = importNpmLock.npmConfigHook;
    npmFlags = [ "--legacy-peer-deps" ];
    PUPPETEER_SKIP_DOWNLOAD = true;
    dontNpmBuild = true;

    passthru = {
      app = {
        type = "app";
        program = drv + "/bin/backstop";
      };

      inherit playwright;
      inherit puppeteer;
    };
  };
in
drv
