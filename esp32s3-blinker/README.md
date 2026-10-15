# __PROJECT_NAME__

ESP32-S3 hourly blinker with a one-time work window.

## Behavior

- **Cold boot:** brings up the radio, runs a ~5-minute work window (WiFi scan,
  BT scan stub, optional I2C scan), then blinks the LED a random number of
  times, logs the count over USB-serial, and deep-sleeps for 1 hour.
- **Every hourly wake:** skips the work window, blinks a random count, logs it,
  sleeps again.

Cold boot vs wake is detected via `wakeup_cause()` (see `lib/src/sleep.rs`).

USB-Serial-JTAG is dead during deep sleep, so all logging happens while awake,
before sleeping.

## Layout

- `lib/` -- reusable modules: `blink`, `sleep`, `wifi`, `bt` (stub), `i2c_scan`,
  each gated by a cargo feature where it pulls heavy deps.
- `firmware/` -- the app: `main.rs` orchestrates boot -> work -> blink -> sleep.

## Verification status

Built by composing API calls verified against current esp-rs docs. The pieces
NOT individually verified (flagged inline in each file):

- esp-radio AP / AP+STA config type names and `AccessPointInfo` fields
- `sleep.rs` enum variant spellings (`SleepSource::Undefined`,
  `SocResetReason::ChipPowerOn`) and `reset_reason` return type
- `i2c_scan` `DriverMode` bound + zero-length-read probe
- BT scan is a stub (entry point known, host API not pinned)
- companion crate versions (embassy-*, esp-alloc) -- let `cargo add` correct

Expect a REPL pass to settle exact names, same as the bootloader-crate fix.

## Tunables

`firmware/src/main.rs`: `LED_GPIO`, `WORK_WINDOW_SECS`, `SLEEP_SECS`.
`lib/src/blink.rs`: `MIN_BLINKS`, `MAX_BLINKS`, blink timing.

Note: the work window currently idles a full `WORK_WINDOW_SECS` *after* the
scans, so total cold-boot awake time is "scan time + 5 min", not exactly 5 min.
Tighten with a deadline if that matters.
