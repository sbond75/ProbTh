# Based on https://github.com/VADL-2022/SIFT/blob/nasa/commonXcode.sh

# Type a script or drag a script file from your workspace to insert its path.
if [ -z "$IN_NIX_SHELL" ]; then
    if [ -e ~/.nix-profile/etc/profile.d/nix.sh ]; then
        source ~/.nix-profile/etc/profile.d/nix.sh
    fi # added by Nix installer
    
    #~/.nix-profile/bin/nix-shell --run "bash \"$0\"" -p opencv pkgconfig
    cd "$SRCROOT/.."
    ~/.nix-profile/bin/nix-shell --run "bash \"$0\""
    exit 0
fi

XCCONFIG="Config.xcconfig"
#truncate –s 0 "$XCCONFIG"
#echo `which pkg-config`
echo "$OPENCV_CFLAGS"
# Demo for compiling that works: `g++ -std=c++11 ginacTest.cpp -lginac -lcln $NIX_CFLAGS_COMPILE $NIX_LDFLAGS`
IFLAGS="$(pkg-config --cflags-only-I ginac cln)"
#echo "$IFLAGS"

# Use a heredoc:
cat <<InputComesFromHERE > "$XCCONFIG"
CXXFLAGS = \$(CXXFLAGS)
HEADER_SEARCH_PATHS=$(echo -n "$IFLAGS" | awk 'BEGIN { ORS=" "; RS = " " } ; { sub(/^-I/, ""); print $0 }')
OTHER_LDFLAGS = -lginac -lcln \$(NIX_LDFLAGS)
CLANG_CXX_LIBRARY=libc++
CLANG_CXX_LANGUAGE_STANDARD=c++11
InputComesFromHERE
