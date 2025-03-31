{
  pyproject-nix,
  pyproject-build-systems,
  uv2nix,

  python, # specify python version outside

  callPackage,
  lib,
  ...
}:
let
  pyproject-util = callPackage pyproject-nix.build.util {};

  # load a uv workspace from a workspace root.
  # uv2nix treats all uv projects as workspace projects.
  workspace = uv2nix.lib.workspace.loadWorkspace {
    workspaceRoot = ./.;
  };

  # create package overlay from workspace.
  overlay = workspace.mkPyprojectOverlay {
    # prefer "wheel" over "sdist" due to maintenance overhead
    sourcePreference = "wheel";
  };

  # construct package set
  pythonSet = (callPackage pyproject-nix.build.packages {
    inherit python;
  }).overrideScope (lib.composeManyExtensions [
    pyproject-build-systems.overlays.default
    overlay
  ]);
in pyproject-util.mkApplication {
  venv = pythonSet.mkVirtualEnv "playlist4progress-env" workspace.deps.default;
  package = pythonSet.playlist4progress;
}