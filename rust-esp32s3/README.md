# __PROJECT_NAME__

no_std Rust for ESP32-S3, using `esp-hal` directly (no ESP-IDF/`std`).

## Why this template looks different from rust-esp32-c6

ESP32-S3 uses the Xtensa LX7 core, not RISC-V. Xtensa support has never
landed in mainline rustc -- it lives in `esp-rs/rust`, a separate compiler
fork maintained by Espressif. That means:

- No `rust-toolchain.toml`. There's no rustup `esp` channel involved at
  all; the flake's devShell puts the fork's `rustc`/`cargo` directly on
  `$PATH`.
- No `rust-overlay`/`fenix` entry, because this isn't a target triple
  stock rustc supports -- it's a whole different compiler build.
- A second toolchain (`xtensa-esp-elf-gcc`) is needed purely as the linker
  driver. The Xtensa LLVM backend can do codegen but not the final link.

Both toolchains are vendored as plain Nix derivations pulling Espressif's
prebuilt release tarballs, hash-pinned. No `espup`, no mutation of
`~/.rustup`.

## First build

```bash
nix develop
just build
```

The Rust/rust-src tarball hashes in `flake.nix` are placeholders
(`lib.fakeHash`) -- the first `nix build` will fail and print the real
hash to paste in. Same idea, twice (rustc tarball, rust-src tarball).

The GCC toolchain's internal directory layout is unverified --
`release-assets.githubusercontent.com` was blocked in the sandbox this
was written in, so I reasoned about the path from Espressif's Docker
examples rather than confirming it directly. If `xtensa-esp32s3-elf-gcc`
isn't found on `$PATH` after `nix develop`, run:

```bash
find /nix/store -maxdepth 2 -iname '*xtensa-esp-elf-gcc*'
find <that store path> -name xtensa-esp32s3-elf-gcc
```

and fix `xtensaGccBin` in `flake.nix` to match.

## Flashing

```bash
just flash
```

GPIO2 is the most common onboard-LED pin on S3 dev boards, but some
boards (e.g. some N16R8 variants) wire it elsewhere. Check yours before
assuming the blinky does anything visible.

## LTO

Deliberately off (`profile.release.lto = "off"` at the workspace root).
The Xtensa LLVM backend has known LTO codegen issues; this isn't a
performance choice, it's a "things actually link" choice.
