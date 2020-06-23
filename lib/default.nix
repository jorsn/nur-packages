{ lib }:

let
  callLibs = file: import file { inherit lib; };
in {
  jorsn = {
    attrsets = {
      setAttrs = names: b: lib.genAttrs names (a: b);
    };

    bool = {
      is = a: b: a == b; # apply partially
    };

    functional = {
      compose = f: g: x: f (g x);
    };


    filesystem = callLibs ./filesystem.nix;

    lists = {
      cons = a: as: [a] ++ as; # apply partially
    };

    strings = {
      getPname = pkg: pkg.pname or lib.getName pkg;
      strip = let
        fromNullOr = default: n: if n == null then default else n;
        headSafe = default: list: if lib.length list == 0 then default else lib.head list;
        match = builtins.match "[[:space:]]*([^[:space:]](.*[^[:space:]])?)[[:space:]]*";
      in s: headSafe "" (fromNullOr [] match s);
    };

  } // {
    inherit (lib.jorsn.attrsets) setAttrs;

    inherit (lib.jorsn.bool) is;
    inherit (lib.jorsn.functional) compose;

    inherit (lib.jorsn.filesystem)
      isRegular isDir isHidden isSymlink isNixFile fileName dirName
      dirPaths listDir fileType listNixDirTrees listNixDirTree listNixDirTree';

    inherit (lib.jorsn.lists) cons;

    inherit (lib.jorsn.strings) strip;
  };
}
