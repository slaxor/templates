# __PROJECT_NAME__

A minimal `no_std` Rust workspace for the STM32F103C8T6 Blue Pill. The workspace separates reusable logic (`lib/`) from the hardware-specific firmware (`firmware/`).

## Development

```sh
nix develop
just build
just flash
```

`just flash` uses `probe-rs` with an ST-Link over SWD. If the chip name is not recognized by your installed `probe-rs`, inspect supported names with `probe-rs chip list | grep -i STM32F103C8` and update `.cargo/config.toml`.

## Wiring

- ST-Link SWDIO → PA13
- ST-Link SWCLK → PA14
- ST-Link GND → Blue Pill GND
- Connect target-voltage sense / VTref according to the ST-Link's documentation.

Do not connect a 5 V supply to the 3.3 V target rail. The onboard LED on common Blue Pill boards is on PC13 and active-low.

## Memory

The default linker layout uses 64 KiB Flash and 20 KiB RAM, matching the nominal STM32F103C8. Some boards use clone parts or different flash sizes; verify the chip and change `firmware/memory.x` if necessary.
