{
  description = "slaxor project templates";
  outputs = { self, ... }: {
    templates = {
      rust-x64 = {
        path = ./rust-x64;
        description = "Plain Rust, native x86_64";
      };
      rust-rp2040 = {
        path = ./rust-rp2040;
        description = "Rust for RaspberryPi Pico (rp2040)";
      };
      rust-rp2350 = {
        path = ./rust-rp2350;
        description = "Rust for RaspberryPi Pico [W] (rp2350)";
      };
      go-cli = {
        path = ./go-cli;
        description = "Plain go, native x86_64";
      };
      go-web = {
        path = ./go-web;
        description = "Go web service, chi router + logging middleware";
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
