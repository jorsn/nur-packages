self: super:

{
  python3Packages = super.python3Packages // {
    sqlalchemy_migrate = super.python3Packages.sqlalchemy_migrate.override {
      tempita = super.python3Packages.callPackage ./pkgs/python/tempita-53.nix {};
    };
  };
  openlp = super.libsForQt5.callPackage ./pkgs/openlp {};
}
