{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    flake-parts.url = "github:hercules-ci/flake-parts";

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
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      perSystem =
        { system, ... }:
        let
          pkgs = import inputs.nixpkgs {
            inherit system;
            config.allowUnfree = true;
            config.permittedInsecurePackages = [
              "xpdf-4.06"
            ];
          };
          ruby = pkgs.ruby;
          rubyNix = (inputs.ruby-nix.lib pkgs) {
            inherit ruby;
            gemset = ./gemset.nix;
          };
          bundix' = pkgs.callPackage ./nix/bundix.nix {
            inherit ruby;
            inherit (inputs) bundix;
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
          _module.args.pkgs = pkgs;
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
        };
    };
}
