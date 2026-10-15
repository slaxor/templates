{
  description = "slaxor project templates";
  outputs = { self, ... }: {
    templates = {
      rust-x64 = {
        path = ./rust-x64;
        description = "Plain Rust, native x86_64";
      };
      rust-esp32c6 = {
        path = ./rust-esp32c6;
        description = "Rust for ESP32C6";
      };
      rust-esp32s3 = {
        path = ./rust-esp32s3;
        description = "Rust for ESP32S3";
      };
      rust-rp2040 = {
        path = ./rust-rp2040;
        description = "Rust for RaspberryPi Pico (rp2040)";
      };
      rust-rp2350 = {
        path = ./rust-rp2350;
        description = "Rust for RaspberryPi Pico [W] (rp2350)";
      };
      rust-stm32f1 = {
        path = ./rust-stm32f1;
        description = "Rust for STM32F1 / Blue Pill (STM32F103C8T6)";
      };
      go-cli = {
        path = ./go-cli;
        description = "Plain go, native x86_64";
      };
      go-web = {
        path = ./go-web;
        description = "Go web service, chi router + logging middleware";
      };
      platformio-stm32 = {
        path = ./platformio-stm32;
        description = "PlatformIO for STM32F103C8T6 Blue Pill";
      };
      shell-tool = {
        path = ./shell-tool;
        description = "Standard Bash env";
      };
      typst-doc = {
        path = ./typst-doc;
        description = "Standard env for a Typst document";
      };
    };
  };
}
