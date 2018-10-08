{ fetchurl,
  lib,
  stdenv,

  # dependencies
  enchant,
  libGL_driver,
  python3Packages,
  qtbase,
  qtmultimedia,
  qttools,

  # flags for optional deps
  enableLibreoffice ? false, libreoffice-fresh,
  enableMySql ? false,
  enablePostgreSql ? false,
  enableJenkinsApi ? false
}:

let
  pythonPackages = python3Packages;
  qtver = lib.concatStringsSep "." (lib.take 2 (builtins.splitVersion qtbase.version));
  prependPath = var: prefix: "export ${var}='${prefix}'\${${var}:+':'}\"$${var}\"";
  qtPluginPath = pkgs:
    let pluginDir = pkg: "${pkg}/lib/qt-${qtver}/plugins";
    in lib.concatStringsSep ":" (map pluginDir pkgs);
  loPythonHook = if !enableLibreoffice then ""
    else prependPath "PYTHONPATH"
      "${libreoffice-fresh.libreoffice.outPath}/lib/libreoffice/program";
  qtPluginHook = prependPath "QT_PLUGIN_PATH" (qtPluginPath [ qtbase.bin qtmultimedia.bin ]);
  pathHooks = "${loPythonHook}\n${qtPluginHook}\n";
in pythonPackages.buildPythonApplication rec {
  name = "OpenLP-${version}";
  version = "2.4.6";

  src = fetchurl {
    url = "get.openlp.org/${version}/${name}.tar.gz";
    sha256 = "f63dcf5f1f8a8199bf55e806b44066ad920d26c9cf67ae432eb8cdd1e761fc30";
  };

  # checks must be disabled because they require access to an X11 display
  doCheck = false;

  prePatch = ''
    patchShebangs .;
  '';

  preCheck = pathHooks;
  preConfigure = pathHooks;

  postInstall = ''
    tdestdir="$out/i18n"
    mkdir -p "$tdestdir"
    cd ./resources/i18n
    for file in *.ts; do
        lconvert -i "$file" -o "$tdestdir/''${file%%ts}qm"
    done
    mv $out/bin/openlp{.py,}
  '';

  checkInputs = with pythonPackages; [ nose Mako ] ++
    lib.optional enableLibreoffice libreoffice-fresh.libreoffice;

  buildInputs = [ qttools.dev ];
  propagatedBuildInputs = [ qtbase.bin qtmultimedia.bin ];

  pythonPath = (with pythonPackages; with lib;
		  [ alembic beautifulsoup4 chardet lxml pyenchant pyodbc pyqt5
		    pyxdg setuptools sip sqlalchemy sqlalchemy_migrate
      ] ++
      optional enableMySql mysql-connector ++
      optional enablePostgreSql psycopg2 ++
      optional enableJenkinsApi jenkinsapi);

  makeWrapperArgs = [
    "--prefix LD_LIBRARY_PATH : '${libGL_driver}/lib'"
    "--prefix LIBGL_DRIVERS_PATH : '${libGL_driver}/lib/dri'"
    "--run '${pathHooks}'"
  ];

  meta = {
    description = "Free church presentation software";
    homepage = https://openlp.org/;
    platforms = lib.platforms.unix;
    license = lib.licenses.gpl2;
    #maintainers = [ ];
  };
}
