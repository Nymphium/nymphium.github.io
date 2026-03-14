{
  inputs = {
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/*";
    flake-utils.url = "github:numtide/flake-utils";

    bundix = {
      url = "github:inscapist/bundix/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ruby-nix = {
      url = "github:inscapist/ruby-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      bundix,
      ruby-nix,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          config.permittedInsecurePackages = [
            "xpdf-4.06"
          ];
        };
        ruby = pkgs.ruby;
        rubyNix = (ruby-nix.lib pkgs) {
          inherit ruby;
          gemset = ./gemset.nix;
        };
        bundix' = pkgs.callPackage ./nix/bundix.nix {
          inherit ruby bundix;
        };
        visual-test = pkgs.callPackage ./nix/visual-test.nix { };

        formatter = pkgs.nixfmt-tree.override {
          settings.formatter.nixfmt = {
            command = "nixfmt";
            includes = [ "*.nix" ];
            excludes = [ "gemset.nix" ];
          };
        };
      in
      {
        legacyPackages = pkgs;
        apps = {
          patched-bundix = bundix'.app;
          visual-screenshots = {
            type = "app";
            program = "${visual-test}/bin/visual-screenshots";
          };
          visual-optimize = {
            type = "app";
            program = "${visual-test}/bin/visual-optimize";
          };
          visual-compare = {
            type = "app";
            program = "${visual-test}/bin/visual-compare";
          };
          visual-diff-report = {
            type = "app";
            program = "${visual-test}/bin/visual-diff-report";
          };
        };
        devShells.default = import ./shell.nix { inherit pkgs rubyNix formatter; };
        inherit formatter;
      }
    );
}
