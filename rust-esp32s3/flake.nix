{
  description = "__PROJECT_NAME__";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
  };

  outputs =
    { nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };

      # esp-rs/rust fork: Xtensa-enabled rustc + cargo. There is no
      # rust-overlay/fenix entry for this -- it's a separate compiler build,
      # not a target triple stock rustc knows about. Versions tracked at
      # https://github.com/esp-rs/rust-build/releases
      xtensaRustVersion = "1.95.0.0";

      xtensaRustc = pkgs.stdenv.mkDerivation {
        pname = "xtensa-rustc";
        version = xtensaRustVersion;

        srcs = [
          (pkgs.fetchurl {
            url = "https://github.com/esp-rs/rust-build/releases/download/v${xtensaRustVersion}/rust-${xtensaRustVersion}-x86_64-unknown-linux-gnu.tar.xz";
            hash = "sha256-qtL7JLrqtq1hxB8ALxNv4LQW7zmlAdKXUKtmwYpplDM=";
          })
          (pkgs.fetchurl {
            url = "https://github.com/esp-rs/rust-build/releases/download/v${xtensaRustVersion}/rust-src-${xtensaRustVersion}.tar.xz";
            hash = "sha256-cIvuM3rC1BwOhhr5MEe//skaBS+8tJV5JdhApB8ydxc=";

          })
        ];

        sourceRoot = ".";
        nativeBuildInputs = [ pkgs.autoPatchelfHook ];
        buildInputs = [
          pkgs.stdenv.cc.cc.lib
          pkgs.zlib
        ];
        dontConfigure = true;
        dontBuild = true;

        installPhase = ''
          runHook preInstall
          mkdir -p $out
          # Verified via: tar tJf <tarball> | head
          # Both tarballs use literal "nightly" in the top-level dir name,
          # not the version string -- this isn't templated on
          # xtensaRustVersion, by design of esp-rs/rust-build's packaging.
          bash ./rust-nightly-x86_64-unknown-linux-gnu/install.sh \
            --destdir=$out --prefix="" --without=rust-docs
          bash ./rust-src-nightly/install.sh \
            --destdir=$out --prefix=""
          runHook postInstall
        '';

        # the bundled rustc/cargo binaries expect a standard FHS-ish dynamic
        # linker layout; autoPatchelfHook rewrites their interpreter/rpath
        # to point at the nix store instead.
        meta.description = "Xtensa-enabled Rust toolchain (esp-rs/rust fork) for ESP32/S2/S3";
      };

      # GCC toolchain providing xtensa-esp32s3-elf-gcc, used only as the
      # linker driver -- the Xtensa LLVM backend in xtensaRustc can't do
      # object emission/linking on its own yet. Hash from Espressif's own
      # esp-idf/tools/tools.json, not a third-party mirror.
      xtensaGcc = pkgs.stdenv.mkDerivation {
        pname = "xtensa-esp-elf-gcc";
        version = "15.2.0_20251204";

        src = pkgs.fetchurl {
          url = "https://github.com/espressif/crosstool-NG/releases/download/esp-15.2.0_20251204/xtensa-esp-elf-15.2.0_20251204-x86_64-linux-gnu.tar.xz";
          sha256 = "3d50f5cd5f173acfd524e07c1cd69bc99585731a415ca2e5bce879997fe602b8";
        };

        nativeBuildInputs = [ pkgs.autoPatchelfHook ];
        buildInputs = [ pkgs.stdenv.cc.cc.lib ];
        dontConfigure = true;
        dontBuild = true;

        installPhase = ''
          runHook preInstall
          mkdir -p $out
          cp -r . $out/
          runHook postInstall
        '';

        # NOTE: the tarball almost certainly unpacks into one wrapping
        # directory (e.g. xtensa-esp-elf/), going by how Espressif's own
        # Docker examples use `tar --strip-components 1`. I could not
        # download+inspect this asset myself (release-assets.githubusercontent.com
        # is blocked in my sandbox), so don't trust a hardcoded bin/ path --
        # confirm it once and fix xtensaGccBin below if wrong:
        #   nix build .#devShells.x86_64-linux.default
        #   find /nix/store -maxdepth 2 -iname '*xtensa-esp-elf-gcc*'
        #   find <that store path> -name xtensa-esp32s3-elf-gcc

        meta.description = "Espressif xtensa-esp-elf GCC/binutils, used as linker driver for esp32/s2/s3";
      };

      # see passthru.findBinDir above -- confirm this path once, you're
      # building blind on my reasoning, not a verified extraction.
      xtensaGccBin = "${xtensaGcc}/xtensa-esp-elf/bin";
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        packages = [
          xtensaRustc
          xtensaGcc
          pkgs.just
          pkgs.espflash
        ];

        # xtensaRustc's bin/ holds rustc+cargo; xtensaGcc's bin/ holds the
        # linker driver cargo invokes by name from .cargo/config.toml.
        shellHook = ''
          export PATH="${xtensaRustc}/bin:${xtensaGccBin}:$PATH"
        '';
      };
    };
}
