with import <nixpkgs> { };
let
  libraries = [ pixman zlib zstd glib libpng ];
in
mkShell {
  buildInputs = libraries;
  nativeBuildInputs = [
  ];

  # make install strips valueable libraries from our rpath
  LD_LIBRARY_PATH = lib.makeLibraryPath libraries;
}
