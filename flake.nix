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
            pkgs.python311Packages.venv
            pkgs.git
          ];

          shellHook = ''
            # Create virtual environment if it doesn't exist
            if [ ! -d .venv ]; then
              python -m venv .venv
            fi

            # Activate the virtual environment
            source .venv/bin/activate

            # Install dagger if not already installed
            if ! pip show dagger-io > /dev/null 2>&1; then
              pip install --upgrade pip
              pip install dagger-io
            fi

            # Install Node packages if needed
            if [ -f package-lock.json ]; then
              npm ci
            else
              npm install
            fi

            echo "Dev environment ready. Python and Node.js are set up."
          '';
        };
      });
}
