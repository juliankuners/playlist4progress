{
  description = "playlist4progress";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    pyproject-nix = {
      url = "github:pyproject-nix/pyproject.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pyproject-build-systems = {
      url = "github:pyproject-nix/build-system-pkgs";
      inputs.pyproject-nix.follows = "pyproject-nix";
      inputs.uv2nix.follows = "uv2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    uv2nix = {
      url = "github:pyproject-nix/uv2nix";
      inputs.pyproject-nix.follows = "pyproject-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      pyproject-nix,
      pyproject-build-systems,
      uv2nix,
      ...
    }:
    let
      playlist4progress = import ./default.nix;
      
      # choose python interpreter version
      pythonVersion = nixpkgs.lib.replaceStrings [ "." "\n" ] [ "" "" ] (builtins.readFile ./.python-version);
      
      passthroughInputs = {
        inherit pyproject-nix pyproject-build-systems uv2nix;
      };
    in flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };

        python = pkgs."python${pythonVersion}";
      in {
        packages.default = pkgs.callPackage playlist4progress (passthroughInputs // { inherit python; });

        devShells.default = pkgs.mkShell {
          packages = [
            python
            pkgs.uv
          ];
          env = {
            # prevent uv from managing Python downloads
            UV_PYTHON_DOWNLOADS = "never";
            # force uv to use nixpkgs Python interpreter
            UV_PYTHON = python.interpreter;
          } // pkgs.lib.optionalAttrs pkgs.stdenv.isLinux {
            # python libraries often load native shared objects using dlopen(3).
            # setting LD_LIBRARY_PATH makes the dynamic library loader aware of libraries without using RPATH for lookup.
            LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath pkgs.pythonManylinuxPackages.manylinux1;
          };
          shellHook = ''
            unset PYTHONPATH
          '';
        };
      }
    ) // {
      overlays.default = final: prev: {
        playlist4progress = final.callPackage playlist4progress (passthroughInputs // { python = final."python${pythonVersion}"; });
      };
    };
}