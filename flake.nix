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
        };
        ruby = pkgs.ruby;
        rubyNix = (ruby-nix.lib pkgs) {
          inherit ruby;
          gemset = ./gemset.nix;
        };
        bundix' = pkgs.callPackage ./nix/bundix.nix {
          inherit ruby bundix;
        };
      in
      {
        legacyPackages = pkgs;
        apps.patched-bundix = {
          type = "app";
          program = bundix' + "/bin/patched-bundix";
        };
        devShells.default = import ./shell.nix { inherit pkgs rubyNix; };
      }
    );
}
