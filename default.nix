# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> {} }:

let
  haskell = pkgs: import ./pkgs/haskell { inherit (pkgs) lib haskell; };
  pkgs' = pkgs.extend (_: pkgs: { haskell = haskell pkgs; });

  inherit (pkgs) callPackage;
in {
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules/nixos; # NixOS modules
  hmModules = import ./modules/home-manager;
  overlays = import ./overlays; # nixpkgs overlays

  haskell = haskell pkgs;
  inherit (pkgs'.haskellPackages) bibi;

  zsh-prompt-gentoo = callPackage ./pkgs/zsh-prompt-gentoo {};
}
