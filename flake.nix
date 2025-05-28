{
  description = "ESP project shell using nixpkgs-esp-dev";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    esp-dev.url = "github:mirrexagon/nixpkgs-esp-dev";
  };

  outputs =
    {
      self,
      nixpkgs,
      esp-dev,
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ (import "${esp-dev}/overlay.nix") ];
      };
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        name = "esp-project";
        buildInputs = with pkgs; [ esp-idf-full ];
      };
    };
}
