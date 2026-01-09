{
  description = "";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";
    git-hooks.url = "github:cachix/git-hooks.nix";
    git-hooks.inputs.nixpkgs.follows = "nixpkgs";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs =
    inputs@{ self, ... }:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.git-hooks.flakeModule
        inputs.treefmt-nix.flakeModule
      ];
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      perSystem =
        {
          config,
          pkgs,
          system,
          ...
        }:
        {
          treefmt = {
            programs.nixfmt.enable = true;
            programs.nixfmt.package = pkgs.nixfmt;
          };
          pre-commit.settings.hooks = {
            treefmt.enable = true;
          };
          devShells.default = pkgs.mkShell {
            inherit (config.pre-commit) shellHook;
            packages = config.pre-commit.settings.enabledPackages;
          };
        };
      flake.templates =
        { lib, ... }:
        let
          entries = builtins.readDir ./.;
          templates = builtins.mapAttrs (name: value: {
            path = ./${name};
            description = "${name} development environment";
          }) lib.filterAttrs (name: value: value == "directory") entries;
        in
        templates;
    };
}
