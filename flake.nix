{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system: 
      let
        pkgs = import nixpkgs {
          inherit system;
        };
        ruby = pkgs.ruby;
        rubyPkgs = pkgs.rubyPackages;
      in
      {
        legacyPackages = pkgs;
        devShells.default = import ./shell.nix { inherit pkgs ruby rubyPkgs; };
      }
    );
}
