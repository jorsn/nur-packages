{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.utils.url = "github:numtide/flake-utils";
  inputs.flake-compat = {
    url = "github:edolstra/flake-compat";
    flake = false;
  };
  inputs.sources.url = "path:./sources";

  outputs = inputs@{ self, nixpkgs, utils, flake-compat, sources }: let
    lib = nixpkgs.lib.recursiveUpdate nixpkgs.lib self.lib;
  in {
    # The `lib`, `modules`, and `overlays` names are special
    lib = import ./lib { inherit (nixpkgs) lib; }; # functions
    modules = import ./modules/nixos; # NixOS modules
    hmModules = import ./modules/home-manager;
    overlays = import ./overlays; # nixpkgs overlays

    overlay = final: prev: let
      inherit (final) callPackage;
    in
    {
      config = lib.recursiveUpdate prev.config { sources = sources.inputs; };

      haskell = import ./pkgs/haskell { inherit lib; inherit (prev) haskell; };
      inherit (final.haskellPackages) bibi;

      ocaml-ng = import ./pkgs/ocaml { inherit lib; inherit (prev) ocaml-ng; };
      inherit (final.ocaml-ng.ocamlPackages_4_07) patoline;

      shellFileBin =  callPackage ./pkgs/build-support/shellFileBin {};

      zsh-prompt-gentoo = callPackage ./pkgs/zsh-prompt-gentoo {};
    };
  } // utils.lib.eachDefaultSystem (system: let
    pkgs = import nixpkgs {
      inherit system;
      overlays = [ self.overlay ] ++ lib.attrValues self.overlays;
    };
  in
  {
    legacyPackages = pkgs;
    packages = lib.filterAttrs (n: v: lib.isDerivation v) (self.overlay pkgs pkgs);
  });
}
