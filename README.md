# playlist4progress
playlist4progress is a tool that shows progress in a XML Shareable Playlist Format (XSPF) formatted file that is used by tools such as VLC. Just provide the index of your current entry and the tool shows your progress.

## Requirements
playlist4progress is written in Python and packaged using Nix. Additionally, Nix provides a development shell that provides Python and [uv](https://docs.astral.sh/uv/) with uv being responsible for managing and resolving Python dependencies. [uv2nix](https://github.com/pyproject-nix/uv2nix) is additionally used to parse the uv lock file within nix. The utilized libraries are enumerated [docs/libraries.md](here).

### How to install Nix
Either use the [NixOS](https://nixos.org/) Linux distribution or install Nix directly on your Linux distribution of choice. You may need to start the daemon or simply restart the system.
```bash
sh <(curl -L https://nixos.org/nix/install) --daemon
```

### How to run in a Nix development shell
A Nix development shell can be used to provide Python and uv. uv in turn can be used to provide a venv and run the project during development. Additionally, the use of [nix-direnv](https://github.com/nix-community/nix-direnv) allows for easy integration into the terminal or an IDE such as VSCode. When using VSCode, the [ruff extension](https://marketplace.visualstudio.com/items?itemName=charliermarsh.ruff) can be installed for linting support.
```bash
nix develop # enter the nix develop shell
uv run playlist4progress --help
exit # exit the nix develop shell
```

### How to build and install with Nix locally
This project is packaged using Nix flakes, Nixpkgs, pyproject-nix, and uv2nix. Run the following to build the project:
```bash
nix build
```
The result will be located in the directory `result`. Please note that Nix built programs are meant to be distributed as packages and not as standalone binaries. This is due to the pure way dynamic libraries are resolved at runtime in Nix.

Run the following to install the project:
```bash
nix profile install
playlist4progress --help
```

### How to install directly
You can install this project directly in your profile by referencing this GitHub repository.
```bash
nix profile install github:juliankuners/playlist4progress
playlist4progress --help
```

## Usage
By default, the name of the playlist file is assumed to be `playlist.xspf`, but a different path can be specified with `--file`. The index of the current track in the playlist must be passed as an argument.

### Example

```bash
$ playlist4progress 10
Part length:  04:48:25
Total length: 22:09:30
Progress:     21.69%
```
