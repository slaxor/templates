//! __PROJECT_NAME__ firmware entry point: embassy executor via esp-rtos,
//! blinking an external LED on GPIO4. See the comment below for why this
//! isn't the onboard LED.
#![no_std]
#![no_main]

use embassy_executor::Spawner;
use embassy_time::Timer;
use esp_backtrace as _;
use esp_hal::{
    clock::CpuClock,
    gpio::{Level, Output, OutputConfig},
    interrupt::software::SoftwareInterruptControl,
    timer::timg::TimerGroup,
};

esp_bootloader_esp_idf::esp_app_desc!();

#[esp_rtos::main]
async fn main(_spawner: Spawner) -> ! {
    let config = esp_hal::Config::default().with_cpu_clock(CpuClock::max());
    let peripherals = esp_hal::init(config);

    let sw_int = SoftwareInterruptControl::new(peripherals.SW_INTERRUPT);
    let timg0 = TimerGroup::new(peripherals.TIMG0);
    esp_rtos::start(timg0.timer0, sw_int.software_interrupt0);

    // This blinks a plain GPIO output on GPIO4 (not a C6 strapping pin:
    // those are GPIO8, GPIO9, GPIO15, MTMS, MTDI). The C6 DevKit boards'
    // onboard LED (GPIO8) is a WS2812 addressable RGB LED, not a simple
    // on/off pin -- driving it needs the RMT peripheral and color framing,
    // which is out of scope for this template. Wire an external LED to
    // GPIO4 (with a resistor) or change the pin to whatever you have.
    let mut led = Output::new(peripherals.GPIO4, Level::Low, OutputConfig::default());
    let interval = __PROJECT_NAME__::blink_interval();

    loop {
        led.set_high();
        Timer::after(interval).await;
        led.set_low();
        Timer::after(interval).await;
    }
}
