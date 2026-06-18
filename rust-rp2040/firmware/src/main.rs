#![no_std]
#![no_main]

use defmt::info;
use embassy_executor::Spawner;
use embassy_rp::gpio::{Level, Output};
use embassy_time::Timer;
use {defmt_rtt as _, panic_probe as _};

#[embassy_executor::main]
async fn main(_spawner: Spawner) {
    let p = embassy_rp::init(Default::default());
    // PIN_25 is the onboard LED on a plain Pico/Pico2.
    // On Pico W/Pico2 W, the LED is wired to the CYW43 wifi chip instead
    // and is not reachable through embassy_rp::gpio directly.
    let mut led = Output::new(p.PIN_25, Level::Low);
    let interval = __PROJECT_NAME__::blink_interval();

    loop {
        led.set_high();
        info!("on");
        Timer::after(interval).await;

        led.set_low();
        info!("off");
        Timer::after(interval).await;
    }
}
