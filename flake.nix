{
  description = "Dev environment for TypeScript HTTP server CI/CD assignment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = [
            pkgs.nodejs_22
            pkgs.python311
            pkgs.python311Packages.pip
            pkgs.git
          ];
          shellHook = ''
            pip install --user dagger-io
            npm install
          '';
        };
      });
}