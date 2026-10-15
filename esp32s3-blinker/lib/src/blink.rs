//! Blink the LED a random number of times.
//!
//! Uses the ESP32-S3 hardware RNG for the count. Returns the count so the
//! caller can log it (logging lives in the binary, not here, so this module
//! stays free of any particular output transport).

use esp_hal::delay::Delay;
use esp_hal::gpio::Output;
use esp_hal::rng::Rng;

/// Inclusive bounds for the random blink count.
const MIN_BLINKS: u32 = 1;
const MAX_BLINKS: u32 = 10;

/// On/off duration of a single blink.
const ON_MS: u32 = 80;
const OFF_MS: u32 = 200;

/// Pick a random count in `MIN_BLINKS..=MAX_BLINKS`, blink the LED that many
/// times, and return the count.
///
/// Blocking: uses `Delay` busy-wait. That's fine here -- this runs in the
/// awake window right before deep sleep, not inside an async executor.
pub fn random_blinks(led: &mut Output<'_>, rng: &mut Rng, delay: &Delay) -> u32 {
    let span = MAX_BLINKS - MIN_BLINKS + 1;
    let count = MIN_BLINKS + (rng.random() % span);
    blink_n(led, delay, count);
    count
}

/// Blink the LED exactly `n` times.
fn blink_n(led: &mut Output<'_>, delay: &Delay, n: u32) {
    for _ in 0..n {
        led.set_high();
        delay.delay_millis(ON_MS);
        led.set_low();
        delay.delay_millis(OFF_MS);
    }
}
