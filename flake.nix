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
        ];
      };
    };
    
}