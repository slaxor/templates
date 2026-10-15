//! I2C bus scanner -- probes 0x08..=0x77 for ACKing devices.
//!
//! VERIFIED against esp-hal 1.1 master::I2c API. The `DriverMode` bound and
//! zero-length-read-as-probe are the two things to double-check if it won't
//! build (some 1.x levels name the marker `esp_hal::Mode`, or need a 1-byte
//! read to drive the address phase).

use esp_hal::i2c::master::I2c;
use heapless::Vec;

const FIRST_ADDR: u8 = 0x08;
const LAST_ADDR: u8 = 0x77;

pub type Found = Vec<u8, 112>;

/// Sweep the bus, return ACKing addresses. Borrows the bus so the caller can
/// keep using it afterwards.
pub fn scan<Dm>(i2c: &mut I2c<'_, Dm>) -> Found
where
    Dm: esp_hal::DriverMode,
{
    let mut found = Found::new();
    for addr in FIRST_ADDR..=LAST_ADDR {
        if i2c.read(addr, &mut []).is_ok() {
            let _ = found.push(addr);
        }
    }
    found
}

/// Scan and print an i2cdetect-style summary.
pub fn scan_and_report<Dm>(i2c: &mut I2c<'_, Dm>)
where
    Dm: esp_hal::DriverMode,
{
    let found = scan(i2c);
    if found.is_empty() {
        esp_println::println!("i2c: no devices");
        return;
    }
    esp_println::print!("i2c: {} device(s):", found.len());
    for addr in &found {
        esp_println::print!(" 0x{addr:02x}");
    }
    esp_println::println!();
}
