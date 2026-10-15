# __PROJECT_NAME__

PlatformIO template for the STM32F103C8T6 Blue Pill, using the Arduino STM32 core and an ST-Link over SWD.

## Build and flash

```sh
nix develop
just build
just flash
```

The onboard LED on common Blue Pill boards is connected to PC13 and is active-low. Board clones vary; verify your board before connecting external hardware.

## Notes

- PlatformIO board ID: `bluepill_f103c8`.
- Upload protocol: `stlink`.
- The ST-Link target must share GND with the board. Connect SWDIO to PA13 and SWCLK to PA14. Connect VTref/3V3 only according to the adapter's documentation; do not feed 5 V into the target.
- If PlatformIO reports that the board's flash size is wrong, check the exact MCU marking and adjust the board configuration accordingly.
