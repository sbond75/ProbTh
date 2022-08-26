# Based on https://github.com/NixOS/nixpkgs/blob/master/pkgs/applications/science/math/ginac/default.nix in commit 9df44cc54023fa59258fc68b17d3061b1aae516b

{ lib, stdenv, fetchurl, cln, pkg-config, readline, gmp, python3 }:

stdenv.mkDerivation rec {
  pname = "ginac";
  version = "1.8.3";

  src = fetchurl {
    url = "https://www.ginac.de/ginac-${version}.tar.bz2";
    sha256 = "sha256-d8caWGrfb8C12rVzQ08wz/FXkVPNd8broCKS4Xj3pJA=";
  };

  propagatedBuildInputs = [ cln ];

  buildInputs = [ readline ]
    ++ lib.optional stdenv.isDarwin gmp;

  nativeBuildInputs = [ pkg-config python3 ];

  strictDeps = true;

  preConfigure = ''
    patchShebangs ginsh
  '';

  configureFlags = [ "--disable-rpath" ];

  meta = with lib; {
    description = "GiNaC is Not a CAS";
    homepage = "https://www.ginac.de/";
    maintainers = with maintainers; [ lovek323 ];
    license = licenses.gpl2;
    platforms = platforms.all;
  };
}











# Based on https://github.com/NixOS/nixpkgs/blob/702d1834218e483ab630a3414a47f3a537f94182/pkgs/applications/science/math/ginac/default.nix#L29

# { lib, stdenv, fetchurl, cln, pkg-config, readline, gmp, python3 }:

# stdenv.mkDerivation rec {
#   pname = "ginac";
#   version = "1.8.1";

#   src = fetchurl {
#     url = "https://www.ginac.de/ginac-${version}.tar.bz2";
#     sha256 = "sha256-8WldvWsYcGHvP7pQdkjJ1tukOPczsFjBb5J4y9z14as=";
#   };

#   propagatedBuildInputs = [ cln ];

#   buildInputs = [ readline ]
#     ++ lib.optional stdenv.isDarwin gmp;

#   nativeBuildInputs = [ pkg-config python3 ];

#   strictDeps = true;

#   preConfigure = ''
#     patchShebangs ginsh
#   '';

#   configureFlags = [ "--disable-dependency-tracking" ];

#   meta = with lib; {
#     description = "GiNaC is Not a CAS";
#     homepage = "https://www.ginac.de/";
#     maintainers = with maintainers; [ lovek323 ];
#     license = licenses.gpl2;
#     platforms = platforms.all;
#   };
# }

# { lib, stdenv, fetchgit, cln, pkg-config, readline, gmp, python3, autoreconfHook, yacc, flex, bison, doxygen }:

# stdenv.mkDerivation rec {
#   pname = "ginac";
#   version = "1.8.3";

#   src = fetchgit {
#     url = "git://www.ginac.de/ginac.git";
#     rev = "release_1-8-3";
#     sha256 = "0md1wai0qh4xvj3c9j5f0y82mygqpb9angs96d01pi73xw60qd22";
#   };

#   propagatedBuildInputs = [ cln ];

#   buildInputs = [ readline ]
#     ++ lib.optional stdenv.isDarwin gmp;

#   nativeBuildInputs = [ pkg-config python3 autoreconfHook yacc flex bison doxygen ];

#   strictDeps = true;

# #   patchPhase = ''
# #      substituteInPlace configure.ac --replace 'AC_PROG_CXX' 'AC_PROG_CC([gcc])
# # AC_PROG_CXX([g++])
# # AC_PROG_CXXCPP([g++])'
# #   '';

#   preConfigure = ''
#     patchShebangs ginsh
#   '';

#   configureFlags = [ "--disable-rpath" "--disable-dependency-tracking" ];

#   meta = with lib; {
#     description = "GiNaC is Not a CAS";
#     homepage = "https://www.ginac.de/";
#     maintainers = with maintainers; [ lovek323 ];
#     license = licenses.gpl2;
#     platforms = platforms.all;
#   };
# }
