//! Deep sleep with hourly timer wake, and wake-reason detection.
//!
//! `sleep_deep` never returns: the chip powers down and resets into `main`
//! from the top on wake. So the control flow is: on each boot, ask *why* we
//! booted (`is_cold_boot`), do the appropriate work, then `deep_sleep_for`
//! which never comes back.
//!
//! USB-Serial-JTAG is powered off in deep sleep -- finish all logging before
//! calling into here.
//!
//! VERIFIED: `reset_reason(Cpu::ProCpu)`, `wakeup_cause()`,
//! `TimerWakeupSource::new(Duration)`, `rtc.sleep_deep(&[&src])` all exist per
//! esp-hal docs. NOT verified, likely needs a tweak: the exact enum-variant
//! spellings below -- `SleepSource::Undefined`, `SocResetReason::ChipPowerOn`,
//! and whether `reset_reason` returns `Option`. If the build complains, check
//! `esp_hal::rtc_cntl` for the real variant names and return type.

use core::time::Duration;
use esp_hal::rtc_cntl::sleep::TimerWakeupSource;
use esp_hal::rtc_cntl::{reset_reason, wakeup_cause, Rtc, SleepSource, SocResetReason};
use esp_hal::system::Cpu;

/// True if this boot is a cold/power-on reset rather than a wake from deep
/// sleep. Use it to gate the one-time 5-minute work window.
///
/// On a timer wake the reset reason is a deep-sleep reset and the wakeup
/// cause is `Timer`; on power-on it's a power-on reset with `Undefined`
/// wakeup cause. We treat "wakeup cause is a real sleep source" as "this was
/// a wake", everything else as a cold boot.
pub fn is_cold_boot() -> bool {
    matches!(wakeup_cause(), SleepSource::Undefined)
}

/// Log the boot reason over USB-serial. Call early, while awake.
pub fn report_boot_reason() {
    let reset = reset_reason(Cpu::ProCpu).unwrap_or(SocResetReason::ChipPowerOn);
    let wake = wakeup_cause();
    esp_println::println!("boot: reset={reset:?} wake={wake:?} cold={}", is_cold_boot());
}

/// Enter deep sleep, waking after `secs`. Never returns.
pub fn deep_sleep_for(rtc: &mut Rtc<'_>, secs: u64) -> ! {
    let timer = TimerWakeupSource::new(Duration::from_secs(secs));
    rtc.sleep_deep(&[&timer]);
    // sleep_deep doesn't return, but the signature here promises `!`, so make
    // that explicit for the type checker.
    unreachable!("sleep_deep returned, which should be impossible")
}
