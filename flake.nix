{
  description = "slaxor project templates";
  outputs = { self, ... }: {
    templates = {
      rust-x64 = {
        path = ./rust-x64;
        description = "Plain Rust, native x86_64";
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
