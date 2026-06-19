#![no_std]
#![no_main]

use esp_hal::{
    clock::CpuClock,
    gpio::{Level, Output, OutputConfig},
    main,
    time::{Duration, Instant},
};

use esp_backtrace as _;
esp_bootloader_esp_idf::esp_app_desc!();

#[main]
fn main() -> ! {
    let config = esp_hal::Config::default().with_cpu_clock(CpuClock::max());
    let peripherals = esp_hal::init(config);

    // GPIO21 is the onboard-LED pin on Xiao ESP32S3 dev boards
    let mut led = Output::new(peripherals.GPIO21, Level::Low, OutputConfig::default());

    loop {
        led.toggle();
        let start = Instant::now();
        while start.elapsed() < Duration::from_millis(500) {}
    }
}
