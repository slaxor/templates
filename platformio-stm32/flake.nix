{
  description = "__PROJECT_NAME__ PlatformIO environment for STM32F103C8T6";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in {
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          platformio-core
          stlink
          just
          python3
        ];
      };
    };
}
