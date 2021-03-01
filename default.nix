# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }:

let
  inherit (lock.nodes.flake-compat.locked) rev narHash;

  lock' = builtins.fromJSON (builtins.readFile ./flake.lock);
  lock  = lock' // {
    nodes = lock'.nodes // {
      # use provided nixpkgs ('pkgs')
      nixpkgs.original = { type = "path"; inherit (pkgs) path; };
    };
  };
  getFlake' = src: (import
    (fetchTarball {
      url = "https://github.com/edolstra/flake-compat/archive/${rev}.tar.gz";
      sha256 = narHash;
    })
    {
      inherit src;
    }).defaultNix;

  flake = (builtins.getFlake or getFlake') (toString ./.);

  pkgs' = pkgs.extend flake.overlay;
  nurPkgs = flake.overlay pkgs' pkgs;
in
nurPkgs // {
  inherit (flake)
    lib
    overlays
    modules
    hmModules
    ;
}
