//! GPIO blinky on the RP2350's RISC-V (Hazard3) core.
//!
//! No embassy here: as of writing, RISC-V mode on the RP2350 lacks a
//! working interrupt dispatcher (no NVIC-equivalent yet), and embassy's
//! executor depends on interrupts. This uses rp235x-hal directly in
//! blocking mode instead. See the README for more on this tradeoff.
#![no_std]
#![no_main]

use panic_halt as _;
use rp235x_hal as hal;

use embedded_hal::delay::DelayNs;
use embedded_hal::digital::OutputPin;

/// Tell the Boot ROM about our application.
#[link_section = ".start_block"]
#[used]
pub static IMAGE_DEF: hal::block::ImageDef = hal::block::ImageDef::secure_exe();

/// External high-speed crystal on the Raspberry Pi Pico 2 board is 12 MHz.
/// Adjust if your board has a different crystal.
const XTAL_FREQ_HZ: u32 = 12_000_000u32;

const BLINK_INTERVAL_MS: u32 = 500;

/// Entry point. `#[hal::entry]` wires this up for whichever core mode
/// (Arm or RISC-V) the binary is built for.
#[hal::entry]
fn main() -> ! {
    let mut pac = hal::pac::Peripherals::take().expect("peripherals already taken");

    let mut watchdog = hal::Watchdog::new(pac.WATCHDOG);
    let clocks = hal::clocks::init_clocks_and_plls(
        XTAL_FREQ_HZ,
        pac.XOSC,
        pac.CLOCKS,
        pac.PLL_SYS,
        pac.PLL_USB,
        &mut pac.RESETS,
        &mut watchdog,
    )
    .expect("clock init failed, check XTAL_FREQ_HZ matches your board");

    let mut timer = hal::Timer::new_timer0(pac.TIMER0, &mut pac.RESETS, &clocks);

    let sio = hal::Sio::new(pac.SIO);
    let pins = hal::gpio::Pins::new(
        pac.IO_BANK0,
        pac.PADS_BANK0,
        sio.gpio_bank0,
        &mut pac.RESETS,
    );

    // PIN_25 is the onboard LED on a plain Pico 2.
    // On Pico 2 W, the LED is wired to the CYW43 wifi chip instead.
    let mut led = pins.gpio25.into_push_pull_output();

    loop {
        led.set_high().expect("gpio output, infallible");
        timer.delay_ms(BLINK_INTERVAL_MS);
        led.set_low().expect("gpio output, infallible");
        timer.delay_ms(BLINK_INTERVAL_MS);
    }
}

/// Program metadata for `picotool info`.
#[link_section = ".bi_entries"]
#[used]
pub static PICOTOOL_ENTRIES: [hal::binary_info::EntryAddr; 5] = [
    hal::binary_info::rp_cargo_bin_name!(),
    hal::binary_info::rp_cargo_version!(),
    hal::binary_info::rp_program_description!(c"__PROJECT_NAME__"),
    hal::binary_info::rp_cargo_homepage_url!(),
    hal::binary_info::rp_program_build_attribute!(),
];
