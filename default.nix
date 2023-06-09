with import <nixpkgs> { };
let
  libraries = [ pixman zlib zstd glib libpng snappy libuuid ];
in
mkShell {
  buildInputs = libraries;
  nativeBuildInputs = [
    # needed to build ovmf
    pkg-config
    nasm
    acpica-tools
  ];
  LD_LIBRARY_PATH = lib.makeLibraryPath libraries;
}