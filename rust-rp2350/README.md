# __PROJECT_NAME__

RP2350 firmware, RISC-V (Hazard3) mode, blocking `rp235x-hal`.

## Why no embassy here

Every other embedded template in this repo uses embassy. This one
doesn't, on purpose.

RP2350's RISC-V cores don't yet have a working interrupt dispatcher
(no NVIC-equivalent to route peripheral interrupts to handlers), and
embassy's executor depends on interrupts to work. So instead of async
tasks, this is a plain blocking polling loop using `rp235x-hal`
directly. If you want async + embassy on this chip, switch to Arm
mode (`thumbv8m.main-none-eabihf`) instead — that combination does work,
just isn't what this template gives you.

## Hardware note

`PIN_25`/`gpio25` is the onboard LED on a plain Pico 2. On a Pico 2 W,
the LED is wired to the CYW43 wifi chip instead and this won't light
anything — you'd need the `cyw43` driver stack for that board.

## Flashing

This uses `picotool`, not `probe-rs` — RISC-V mode on RP2350 isn't
something probe-rs flashes (Arm mode is, via ADIv6 support added in
probe-rs 0.27.0, but that's not what this template targets).

```
just run
```

Put the board in BOOTSEL mode first (hold BOOTSEL, plug in USB, or
reset while held) if it doesn't drop into bootloader mode on its own.

### udev rule (Linux, one-time, per host)

picotool needs unprivileged USB access to the device. Add:

```
# /etc/udev/rules.d/99-picotool.rules
SUBSYSTEM=="usb", ATTRS{idVendor}=="2e8a", ATTRS{idProduct}=="000f", MODE="0666"
```

(`000f` is the RP2350's BOOTSEL-mode product ID, distinct from RP2040's
`0003`.) Reload with `udevadm control --reload-rules && udevadm trigger`,
or on NixOS add the rule via `services.udev.extraRules` in your host
config — this is a host-level concern, not something the project flake
can provide.

## Layout

Flat single-crate, not a workspace — there's no async task logic here
worth splitting into a separate lib crate, unlike the embassy-based
templates.

`memory.x` and `rp235x_riscv.x` are vendored verbatim from
[rp-rs/rp-hal](https://github.com/rp-rs/rp-hal) (MIT/Apache-2.0), not
hand-written — the RP2350 boot-block/picotool-metadata section layout
is fiddly enough that copying the upstream-maintained version is safer
than reconstructing it.
