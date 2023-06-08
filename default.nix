with import <nixpkgs> { };
let
  libraries = [ pixman zlib zstd glib libpng snappy ];
in
mkShell {
  buildInputs = libraries;
  nativeBuildInputs = [
    #for the sev-tool
    # autoconf
    # automake

    # #for sev guest
    # ninja
    # nasm
    # acpica-tools
    # flex
    # bison
    # elfutils
    # smatch
    # rpm

    # #general
    # # bc
    # # dnsmasq
    # pkg-config
    # libvirt
    # virt-manager
    # vim
    # libuuid
    # # file
    # bridge-utils
    # cloud-utilsubun
    # openssl
    # #for the controller
    # cmake
    # git
    # clang
    # cppcheck
    # # doxygen
    # # codespell
    # # abseil-cpp
  ];
  LD_LIBRARY_PATH = lib.makeLibraryPath libraries;
}
