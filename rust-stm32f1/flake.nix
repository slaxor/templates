{
  description = "__PROJECT_NAME__ Rust environment for STM32F103C8T6";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = { nixpkgs, rust-overlay, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ rust-overlay.overlays.default ];
      };
      rust = pkgs.rust-bin.stable.latest.default.override {
        targets = [ "thumbv7m-none-eabi" ];
        extensions = [ "rust-src", "rust-analyzer" ];
      };
    in {
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          rust
          just
          probe-rs-tools
          stlink
          gcc-arm-embedded
        ];
      };
    };
}
