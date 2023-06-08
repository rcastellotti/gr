{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
  };
  outputs = { self, nixpkgs }:
    let pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in {
      devShell.x86_64-linux = pkgs.mkShell {
        packages = with pkgs; [
          pkg-config
          pixman
          zlib
          zstd 
          glib 
          libpng
          # needed for ./build.sh ovmf
          libuuid


          # remove
          cpuid
          dmidecode
          msr
          msr-tools
          unzip
          rpm

    #for the sev-tool
    autoconf
    automake

    #for sev guest
    ninja
    nasm
    acpica-tools
    flex
    bison
    elfutils
    smatch

    #general
    bc
    bashInteractive
    dnsmasq
    bridge-utils
    cloud-utils
    openssl
        ];
          LD_LIBRARY_PATH = lib.makeLibraryPath libraries;

      };
    };
    
}