{
  inputs = {
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/*.tar.gz";
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
        rubyNix = (ruby-nix.lib pkgs) {
          inherit (pkgs) ruby;
          gemset = ./gemset.nix;
        };
        bundixcli = bundix.packages.${system}.default;
      in
      {
        legacyPackages = pkgs;
        devShells.default = import ./shell.nix { inherit pkgs rubyNix bundixcli; };
      }
    );
}
