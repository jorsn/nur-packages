# You can use this file as a nixpkgs overlay. This is useful in the
# case where you don't want to add the whole NUR namespace to your
# configuration.

final: prev:

let
  getFlake' = src: import ./flake-compat.nix src {
    nixpkgs = { type = "path"; inherit (prev) path; };
  }.defaultNix;

  flake = (builtins.getFlake or getFlake') (toString ./.);
in
  flake.overlay final prev
