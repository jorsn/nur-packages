src:
inputs:

let
  inherit (lock.nodes.flake-compat.locked) rev narHash;

  lock' = builtins.fromJSON (builtins.readFile (/. + src + "/flake.lock"));
  lock  = if inputs == {} then lock' else lock' // {
    nodes = lock'.nodes // builtins.mapAttrs (_: original: { inherit original; }) inputs;
  };
in

import
  (fetchTarball {
    url = "https://github.com/edolstra/flake-compat/archive/${rev}.tar.gz";
    sha256 = narHash;
  })
  {
    inherit src;
  }
