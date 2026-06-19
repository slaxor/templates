# __PROJECT_NAME__

ESP32-C6 firmware, RISC-V, esp-hal + embassy via esp-rtos.

## Toolchain note

C6 is RISC-V, so this builds with stock upstream Rust (unlike the
ESP32-S3, which needs Espressif's Xtensa toolchain fork via `espup`/a
custom Nix derivation -- see the `rust-esp32s3` template for that mess).

One thing worth flagging honestly: `.cargo/config.toml` sets
`[unstable] build-std = ["core"]`, which historically requires a nightly
cargo. Espressif's own tooling documentation states RISC-V targets use
the stable channel, and `rust-toolchain.toml` here pins `stable` --
but if `cargo build` complains about `build-std` needing nightly, try
`cargo +nightly build` once to confirm whether your toolchain version
actually honors `[unstable]` on stable. This wasn't possible to verify
end-to-end without real hardware/network access while building this
template.

## Architecture note

This crate ecosystem went through a recent consolidation:
`esp-hal-embassy` and `esp-wifi` no longer exist as separate crates --
they're merged into `esp-rtos` (embassy executor + RTOS primitives) and
`esp-radio` (wifi/BLE), respectively. If you find older tutorials
referencing `esp_hal::embassy::init` or `esp-wifi`, they're describing
a prior API generation; this template uses the current
`esp_rtos::start()` + `#[esp_rtos::main]` pattern.

## Hardware note

GPIO8 is the onboard LED on ESP32-C6-DevKitC-1/DevKitM-1 boards, but
it's a WS2812 addressable RGB LED, not a plain digital pin -- driving
it needs the RMT peripheral and color-frame encoding, which this
template doesn't attempt. The code blinks a plain LED wired externally
to GPIO4 instead (not a C6 strapping pin). Change the pin in
`firmware/src/main.rs` to whatever you've actually wired up.

## Flashing

```
just run
```

Uses `espflash`, which talks directly to the chip's USB-JTAG/serial in
download mode -- no separate debug probe needed for basic flash+monitor.

### udev rule (Linux, one-time, per host)

```
# /etc/udev/rules.d/99-esp32.rules
SUBSYSTEMS=="usb", ATTRS{idVendor}=="303a", TAG+="uaccess"
```

(`303a` is Espressif's USB vendor ID, used by C6's native USB-JTAG/Serial.
`TAG+="uaccess"` grants access to the active desktop session rather than
all local users, which is preferable to the older `MODE="0666"` pattern
seen in a lot of older guides.) Reload with
`udevadm control --reload-rules && udevadm trigger`, or add the rule via
`services.udev.extraRules` in your NixOS host config.

## Layout

`lib`/`firmware` workspace split, same shape as the `rust-rp2040`
template: `lib` holds reusable async-independent logic, `firmware` is
the embassy entrypoint.
