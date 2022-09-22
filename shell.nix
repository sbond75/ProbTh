# { pkgs ? (builtins.fetchTarball { # https://nixos.wiki/wiki/FAQ/Pinning_Nixpkgs :
#   # Descriptive name to make the store path easier to identify
#   name = "nixos-unstable-2022-02-12";
#   #name = "nixos-unstable-2022-06-02";
#   # Commit hash for nixos-unstable as of the date above
#   url = "https://github.com/NixOS/nixpkgs/archive/154d72f526d800863066ae9d5b770458dc3c40a0.tar.gz";
#   #url = "https://github.com/NixOS/nixpkgs/archive/d2a0531a0d7c434bd8bb790f41625e44d12300a4.tar.gz";
#   # Hash obtained using `nix-prefetch-url --unpack <url>`
#   sha256 = "0pkm7zq05xd0f0xwxrkk3mfbhckwndlb3zkf5fn44kxd2m04yw8c";
#   #sha256 = "13nwivn77w705ii86x1s4zpjld6r2l197pw66cr1nhyyhi5x9f7d";
# })}:

{ pkgs ? import (builtins.fetchTarball { # https://nixos.wiki/wiki/FAQ/Pinning_Nixpkgs :
  # Descriptive name to make the store path easier to identify
  name = "nixos-unstable-2022-02-12";
  #name = "nixos-unstable-2022-06-02";
  # Commit hash for nixos-unstable as of the date above
  url = "https://github.com/NixOS/nixpkgs/archive/154d72f526d800863066ae9d5b770458dc3c40a0.tar.gz";
  #url = "https://github.com/NixOS/nixpkgs/archive/d2a0531a0d7c434bd8bb790f41625e44d12300a4.tar.gz";
  # Hash obtained using `nix-prefetch-url --unpack <url>`
  sha256 = "0pkm7zq05xd0f0xwxrkk3mfbhckwndlb3zkf5fn44kxd2m04yw8c";
  #sha256 = "13nwivn77w705ii86x1s4zpjld6r2l197pw66cr1nhyyhi5x9f7d";
}) { }}:
with pkgs;

# # Apply overlay
# let
#   # myOverlay = (self: super: {
#   #   stdenv = super.gcc11Stdenv;
#   # });
#   nixpkgs = import pkgs {};
#   finalPkgs = import pkgs {
#     system = if (nixpkgs.hostPlatform.isDarwin) then "x86_64-darwin" else builtins.currentSystem; # For M1 Mac to work
#     # Identity: overlays = [];
#     # overlays = [ myOverlay ];
    
#     overlays = [ (final: prev: {
#       pkgs11 = pkgs {
#         overlays = [
#           (final': prev': {
#             #stdenv = prev.gcc11Stdenv;
#             cc = prev.gcc;
#           })
#         ];
#       };
#     })];
#   };
# in
# with finalPkgs;

# let
#   boostPython = boost.override { enablePython = true; inherit python3; };
# in
# mkShell.override{stdenv = gcc11Stdenv;} {

let
  boostPython = python3Packages.boost;
  #boostPython = boost.override { enablePython = true; inherit python3; };

  pyginac = (callPackage ./nix/PyGiNaC.nix {buildPythonPackage=python3Packages.buildPythonPackage;});
in
mkShell {
  # buildInputs = [
  #   (callPackage ./nix/PyGiNaC.nix {})
  # ];
  
  buildInputs = [
    # gnumake which pkg-config
    #ginac
    (callPackage ./nix/ginac.nix {})
    # cln python3Packages.boost
    # python3
    # darwin.apple_sdk.frameworks.CoreFoundation

    # readline
    # gmp





    (python3.withPackages(ps: with ps; [
      pyginac
      sympy
    ]))
    pkg-config
    
    # (callPackage ./nix/ginac.nix {})
    # cln
    # python3
    # darwin.apple_sdk.frameworks.CoreFoundation
    # boostPython
    # ncurses
  ];
  
  shellHook = ''
    export PYTHONPATH="$PYTHONPATH:${pyginac}/lib/python3.9/site-packages:${python3Packages.sympy}/lib/python3.9/site-packages:${python3Packages.mpmath}/lib/python3.9/site-packages"
  '';
}
