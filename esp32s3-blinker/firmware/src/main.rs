#![no_std]
#![no_main]

//! __PROJECT_NAME__
//!
//! Lifecycle:
//!   cold boot  -> 5-minute work window (wifi scan, bt stub, i2c scan)
//!             \-> blink random count + log -> deep sleep 1h
//!   timer wake -> blink random count + log -> deep sleep 1h
//!
//! The work window needs the async radio stack, so we boot the esp-rtos
//! Embassy executor. The blink+log+sleep tail is plain blocking code run
//! after the async work is done.

use embassy_executor::Spawner;
use embassy_time::{Duration as ETimerDuration, Timer};
use esp_hal::clock::CpuClock;
use esp_hal::delay::Delay;
use esp_hal::gpio::{Level, Output, OutputConfig};
use esp_hal::rng::Rng;
use esp_hal::rtc_cntl::Rtc;
use esp_hal::timer::timg::TimerGroup;
use esp_println::println;

use lib::{blink, sleep};

esp_bootloader_esp_idf::esp_app_desc!();

/// Cold-boot work window length.
const WORK_WINDOW_SECS: u64 = 5 * 60;
/// Sleep duration between hourly wakes.
const SLEEP_SECS: u64 = 60 * 60;

#[esp_rtos::main]
async fn main(spawner: Spawner) {
    let config = esp_hal::Config::default().with_cpu_clock(CpuClock::max());
    let peripherals = esp_hal::init(config);

    esp_alloc::heap_allocator!(#[unsafe(link_section = ".dram2_uninit")] size: 72 * 1024);

    let timg0 = TimerGroup::new(peripherals.TIMG0);
    esp_rtos::start(timg0.timer0);

    sleep::report_boot_reason();

    let mut rtc = Rtc::new(peripherals.LPWR);
    let delay = Delay::new();
    let mut rng = Rng::new();

    // LED on GPIO2 (common on S3 devkits; change for your board). Re-created
    // each boot since deep sleep resets everything.
    let mut led = Output::new(peripherals.GPIO2, Level::Low, OutputConfig::default());

    // --- cold boot only: the 5-minute work window ---
    if sleep::is_cold_boot() {
        println!("cold boot: running {WORK_WINDOW_SECS}s work window");
        run_work_window(&spawner, peripherals.WIFI, peripherals.BT).await;
    } else {
        println!("timer wake: skipping work window");
    }

    // --- every boot: blink a random number of times, log it ---
    let count = blink::random_blinks(&mut led, &mut rng, &delay);
    println!("blinked {count} time(s)");

    // --- every boot: deep sleep until the next hourly wake (never returns) ---
    println!("sleeping for {SLEEP_SECS}s");
    sleep::deep_sleep_for(&mut rtc, SLEEP_SECS)
}

/// The cold-boot work window: bring up the radio, scan wifi, poke bt, then
/// idle out the remainder of the 5 minutes. I2C scan happens here too if you
/// wire a bus (left commented since it needs pins chosen for your board).
async fn run_work_window(
    _spawner: &Spawner,
    wifi: esp_hal::peripherals::WIFI<'static>,
    bt: esp_hal::peripherals::BT<'static>,
) {
    let radio = &*lib::mk_static!(
        esp_radio::Controller<'static>,
        esp_radio::init().expect("radio init failed")
    );

    // WiFi scan
    match lib::wifi::start(radio, wifi) {
        Ok(mut w) => {
            lib::wifi::scan_and_report(&mut w.controller, 16).await;
            // To exercise STA/AP, call lib::wifi::into_sta / into_ap here.
        }
        Err(e) => println!("wifi: start failed: {e:?}"),
    }

    // BT scan (stub for now)
    lib::bt::placeholder(bt);

    // I2C scan -- uncomment and pick pins for your board:
    // let mut i2c = esp_hal::i2c::master::I2c::new(
    //     peripherals.I2C0,
    //     esp_hal::i2c::master::Config::default()
    //         .with_frequency(esp_hal::time::Rate::from_khz(400)),
    // ).unwrap()
    //  .with_scl(peripherals.GPIO9)
    //  .with_sda(peripherals.GPIO8);
    // lib::i2c_scan::scan_and_report(&mut i2c);

    // Idle out the rest of the work window.
    println!("work done, idling out the window");
    Timer::after(ETimerDuration::from_secs(WORK_WINDOW_SECS)).await;
}
