{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system: 
      let
        pkgs = nixpkgs.legacyPackages.${system};
        inherit (pkgs) ruby;
        gems = pkgs.bundlerEnv {
          name = "gems-for-blog";
          inherit ruby;
          gemdir = ./.;
        };
      in
      {
        devShells.default = import ./shell.nix { inherit pkgs gems ruby; };
      }
    );
}
