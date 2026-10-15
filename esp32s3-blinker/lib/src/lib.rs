#![no_std]

//! Building blocks for __PROJECT_NAME__.
//!
//! The app does a one-time 5-minute "work window" on cold boot (wifi/bt/i2c),
//! then settles into an hourly cycle: wake -> blink a random number of times
//! -> log the count over USB-serial -> deep sleep. USB-Serial-JTAG is dead
//! during deep sleep, so all logging happens while awake, before sleeping.

#[cfg(feature = "_radio")]
extern crate alloc;

/// Promote a value to `'static` on stable. esp-radio controllers, executors,
/// and net stacks all want `'static` handles.
#[cfg(feature = "_radio")]
#[macro_export]
macro_rules! mk_static {
    ($t:ty, $val:expr) => {{
        static STATIC_CELL: ::static_cell::StaticCell<$t> = ::static_cell::StaticCell::new();
        #[deny(unused_attributes)]
        let x = STATIC_CELL.uninit().write(($val));
        x
    }};
}

pub mod blink;
pub mod sleep;

#[cfg(feature = "i2c-scan")]
pub mod i2c_scan;

#[cfg(feature = "wifi")]
pub mod wifi;

#[cfg(feature = "bt")]
pub mod bt;
