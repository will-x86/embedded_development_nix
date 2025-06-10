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
          arduino-language-server # requirement by Arduino-Nvim
          lua51Packages.dkjson # requirement by Arduino-Nvim
          arduino-cli # requirement by Arduino-Nvim
          libudev-zero
          picotool
          # arduino-cli config init
          #arduino-cli core update-index
          #arduino-cli core install arduino:avr
          clang-tools # requirement by Arduino-Nvim
        ];
        shellHook = ''
          if [ ! -f ~/.arduino15/arduino-cli.yaml ]; then
            arduino-cli config init
          fi

          # Update cores if needed
          #arduino-cli core update-index

          echo "Arduino development environment ready!"WD/.platformio
          export LD_LIBRARY_PATH="${pkgs.libudev-zero}/lib:${pkgs.systemd}/lib:$LD_LIBRARY_PATH"
          export CLANGD_IDF_PATH=$(which clangd)

        '';
      };
    };
}
