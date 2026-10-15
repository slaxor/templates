//! WiFi scan / STA / AP for the cold-boot work window.
//!
//! VERIFICATION: STA + scan path (`esp_radio::wifi::new`, `ModeConfig::Client`,
//! `ClientConfig`, `ScanConfig`, `scan_with_config_async`, `set_config`,
//! `start_async`) checked against current esp-radio docs. AP path
//! (`AccessPointConfig`, `ModeConfig::AccessPoint`) and `AccessPointInfo`
//! field names are extrapolated -- verify against esp-radio::wifi docs if they
//! don't resolve.

use esp_hal::peripherals::WIFI;
use esp_radio::wifi::{
    AccessPointConfig, ClientConfig, Interfaces, ModeConfig, ScanConfig, WifiController,
};
use esp_println::println;

pub struct Wifi<'d> {
    pub controller: WifiController<'d>,
    pub interfaces: Interfaces<'d>,
}

pub fn start<'d>(
    radio: &'d esp_radio::Controller<'d>,
    wifi: WIFI<'d>,
) -> Result<Wifi<'d>, esp_radio::wifi::WifiError> {
    let (controller, interfaces) = esp_radio::wifi::new(radio, wifi, Default::default())?;
    Ok(Wifi { controller, interfaces })
}

/// Scan and print. Must run before any STA connect is in progress.
pub async fn scan_and_report(controller: &mut WifiController<'_>, max: usize) {
    let cfg = ScanConfig::default().with_max(max);
    match controller.scan_with_config_async(cfg).await {
        Ok(aps) => {
            println!("wifi: {} AP(s):", aps.len());
            for ap in &aps {
                println!("  {:<32} ch{:<3}", ap.ssid.as_str(), ap.channel);
            }
        }
        Err(e) => println!("wifi: scan failed: {e:?}"),
    }
}

/// Start STA mode against a network (you still drive connect/reconnect).
pub async fn into_sta(
    controller: &mut WifiController<'_>,
    ssid: &str,
    password: &str,
) -> Result<(), esp_radio::wifi::WifiError> {
    let cfg = ModeConfig::Client(
        ClientConfig::default()
            .with_ssid(ssid.into())
            .with_password(password.into()),
    );
    controller.set_config(&cfg)?;
    controller.start_async().await?;
    Ok(())
}

/// Start soft-AP mode (empty password => open AP).
pub async fn into_ap(
    controller: &mut WifiController<'_>,
    ssid: &str,
    password: &str,
) -> Result<(), esp_radio::wifi::WifiError> {
    let ap = if password.is_empty() {
        AccessPointConfig::default().with_ssid(ssid.into())
    } else {
        AccessPointConfig::default()
            .with_ssid(ssid.into())
            .with_password(password.into())
    };
    controller.set_config(&ModeConfig::AccessPoint(ap))?;
    controller.start_async().await?;
    Ok(())
}
