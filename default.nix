with import <nixpkgs> { };
let
  libraries = [ libslirp pixman zlib zstd glib libpng snappy libuuid];
in
mkShell {
  buildInputs = libraries;
  nativeBuildInputs = [
    git
    # needed to compile qemu with user network support
    ninja
    gnumake
    flex
    bison
    # needed to build ovmf
    pkg-config
    nasm
    acpica-tools
    # needed for the first demo
    gdb
    # needed to run cpuid
    cpuid
  ];
  LD_LIBRARY_PATH = lib.makeLibraryPath libraries;
}
