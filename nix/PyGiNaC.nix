{ lib, stdenv, fetchgit, gnumake, which, python3, pkg-config, ginac, cln, #gcc,
  #boost,
  python3Packages,
  darwin, callPackage, ncurses, buildPythonPackage }:

buildPythonPackage rec {
  name = "PyGiNaC";
  version = "v1.5.10";

  nativeBuildInputs = [ gnumake which pkg-config #gcc
                      ];

  #boostPython = boost.override { enablePython = true; inherit python3; };
  boostPython = python3Packages.boost;
  
  buildInputs = [
    #ginac
    (callPackage ./ginac.nix {})
    cln
    python3
    darwin.apple_sdk.frameworks.CoreFoundation
    boostPython
    ncurses
  ];

  preBuild = ''
    export DESTDIR=$out/

    export BOOST_PYTHON_LIB="boost_python${"${lib.versions.major python3.version}${lib.versions.minor python3.version}"}"
  '';
  
  patchPhase = ''
    substituteInPlace Makefile --replace 'prefix = /usr/local
includedir =  $(prefix)/include
libdir = $(prefix)/lib/python3/dist-packages
datarootdir = $(prefix)/share
docdir = $(datarootdir)/doc/python3-pyginac' 'prefix = $out
includedir =  include
libdir = ${python3.sitePackages}
datarootdir = share
docdir = $(datarootdir)/doc/python3-pyginac' --replace '$(DESTDIR)/usr/include/' '$(DESTDIR)/include/' --replace '$(DESTDIR)$(prefix)' '$(prefix)' --replace '-Wl,--version-script=linux-symbols.map -Wl,-no-undefined -Wl,--verbose' "" --replace 'ifeq ($(DISTRO_NAME),bionic)
BOOST_PYTHON_LIB=boost_python3
#BOOST_PYTHON_LIB=boost_python-py3$(PYTHON_VERSION_MINOR)
else
BOOST_PYTHON_LIB=boost_python$(PYSUFFIX)3$(PYTHON_VERSION_MINOR)
endif' "" --replace "GXX = g++" "GXX = c++" --replace "$(echo -e 'install:\n\tmake default')" "$(echo -e '.PHONY: install\ninstall:\n\tmake default')"
  '';

  preInstall = ''
    mkdir "$out"
    mkdir "$out/include"
  '';
  
  # src = fetchcvs {
  #   cvsRoot = ":pserver:anonymous@cvs.sourceforge.net:/cvsroot/pyginac";
  #   module = "pyginac";
  #   date = version;
  #   sha256 = "...etc...";
  # };

  src = fetchgit {
    url = "git://git.code.sf.net/p/moebinv/pyginac/code";
    sha256 = "02giflwdg09k2zn7gi2cb89cb09bgfqf0ijrsir1n7qfw0mrv9ln";
  };
}
