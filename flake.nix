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
      #customPython = pkgs.python310.withPackages (
      #  ps: with ps; [
      #    numpy # Example: Add Python libraries you may need
      #    pyserial # Required by some PlatformIO workflows
      #  ]
      #);

      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ (import "${esp-dev}/overlay.nix") ];
      };
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        name = "esp-project";
        buildInputs = with pkgs; [
          esp-idf-full # espressif stuff
          screen # monitoring
          #platformio-core - causes breaking as it downloads binaries nixos can't run
          platformio
          #customPython
          #esptool
          bear
        ];
        shellHook = ''
          export PLATFORMIO_CORE_DIR=$PWD/.platformio
        '';
      };
    };
}
