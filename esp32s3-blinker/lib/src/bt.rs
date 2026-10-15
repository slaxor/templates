//! BLE scanning -- STUB.
//!
//! Entry point is known; the host-stack scan API is not pinned, so it's a TODO
//! rather than a guess.
//!
//! Confirmed wiring:
//!   - esp-radio built with `ble` feature.
//!   - Controller: `esp_radio::ble::controller::BleConnector::new(radio, bt)`.
//!   - On top: a host stack. `trouble-host` (current, recommended) or `bleps`
//!     (older, esp-rs-specific). For a scanner you want central/observer role
//!     and drain advertising reports.
//!
//! TODO:
//!   1. Choose host (trouble-host recommended), add dep behind `bt`.
//!   2. BleConnector -> host -> scanner.
//!   3. async fn scan(...) -> Vec<report> over a bounded window, mirroring
//!      wifi::scan_and_report.

use esp_hal::peripherals::BT;

/// Placeholder so the feature wiring compiles. Replace per TODO.
pub fn placeholder(_bt: BT<'_>) {
    esp_println::println!("bt: scan not yet implemented (stub)");
}
