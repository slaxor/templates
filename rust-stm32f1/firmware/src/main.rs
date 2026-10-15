#![no_std]
#![no_main]

use cortex_m_rt::entry;
use embedded_hal::digital::v2::OutputPin;
use panic_halt as _;
use stm32f1xx_hal::{
    delay::Delay,
    pac,
    prelude::*,
};

#[entry]
fn main() -> ! {
    let device = pac::Peripherals::take().unwrap();
    let core = cortex_m::Peripherals::take().unwrap();

    let mut flash = device.FLASH.constrain();
    let rcc = device.RCC.constrain();
    let clocks = rcc.cfgr.freeze(&mut flash.acr);
    let mut delay = Delay::new(core.SYST, clocks);

    let mut gpio_c = device.GPIOC.split();
    let mut led = gpio_c.pc13.into_push_pull_output(&mut gpio_c.crh);

    loop {
        let _ = led.set_low();
        delay.delay_ms(500_u16);
        let _ = led.set_high();
        delay.delay_ms(500_u16);
    }
}
