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

        python-with-packages = pkgs.python311.withPackages (ps: with ps; [
          pip
          dagger-io
        ]);
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = [
            pkgs.nodejs_22
            python-with-packages
            pkgs.git
          ];

          shellHook = ''
            echo "Dev environment ready."
            echo "Python: $(python --version)"
            echo "Node: $(node --version)"
            echo "Dagger: $(python -m dagger --version || true)"
          '';
        };
      });
}
