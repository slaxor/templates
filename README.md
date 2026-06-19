 slaxor/templates

A collection of **Nix flake templates** for Rust, Go, embedded targets, shell tooling, and Typst workflows — designed to be used directly via `nix flake init` or the `mkprj` scaffolding script.

---

## 📦 Available Templates

These templates can be used with:

```bash
nix flake init -t codeberg:slaxor/templates#<template>
Rust
rust-x64
Plain Rust project for native x86_64
rust-esp32c6
Rust environment for ESP32-C6 embedded development
rust-esp32s3
Rust environment for ESP32-S3 embedded development
rust-rp2040
Rust setup for Raspberry Pi Pico (RP2040)
rust-rp2350
Rust setup for Raspberry Pi Pico W (RP2350)
Go
go-cli
Minimal Go CLI project for native development
go-web
Go web service using chi router with logging middleware
Other
shell-tool
Standard Bash-based development environment
typst-doc
Typst document environment for writing and building .typst files
🚀 Recommended Workflow (mkprj)

This repository includes a helper script: mkprj

It wraps nix flake new and adds:

template fetching from Codeberg
project name normalization
git initialization
optional direnv integration
in-place placeholder substitution
🛠️ Install mkprj

Clone this repo and make the script available:

git clone https://codeberg.org/slaxor/templates.git
cd templates
chmod +x mkprj.sh

Optionally symlink it:

ln -s $(pwd)/mkprj.sh ~/.local/bin/mkprj
📁 Usage (mkprj)
Create a new project
mkprj new <template> <path>

Example:

mkprj new rust-x64 my-project
List templates
mkprj list

This queries the flake directly:

nix eval codeberg:slaxor/templates#templates \
  --apply builtins.attrNames --json
Force refresh (important)

Nix caches flake revisions. If you add new templates and they don’t appear:

mkprj list --refresh
mkprj new --refresh rust-x64 my-project
🔧 Template substitution

When creating a project, mkprj:

replaces __PROJECT_NAME__ in files
renames files containing __PROJECT_NAME__
initializes a git repository
creates a .envrc with:
use flake

If direnv is installed, it will automatically run direnv allow .

🧪 Example
mkprj new rust-esp32s3 sensor-node
cd sensor-node
direnv allow
🧱 Direct flake usage (no mkprj)

You can also use templates manually:

nix flake init -t codeberg:slaxor/templates#go-web
nix develop
📂 Repository Structure
.
├── flake.nix
├── mkprj.sh
├── rust-x64/
├── rust-esp32c6/
├── rust-esp32s3/
├── rust-rp2040/
├── rust-rp2350/
├── go-cli/
├── go-web/
├── shell-tool/
└── typst-doc/
📄 License

Add your license here.

🤝 Contributing

Contributions are welcome:

keep templates minimal and reproducible
ensure nix flake check works
avoid unnecessary dependencies
prefer clarity over cleverness in embedded targets
Your workflow (assumed):
```mermaid
---
config:
  layout: elk
---
flowchart TD
    A[Start: NixOS System] --> B[Create flake.nix]
    B --> C[Define Rust Dev Dependencies]
    C --> D[Create devShell Output]
    D --> E[Configure direnv]
    E --> F[Create .envrc File]
    F --> G[Set direnv Allow]
    G --> H[Direnv Loads Shell]
    H --> I[Access Dev Environment]
    I --> J[Select Nix Template]
    J --> K{Template Type}
    K -->|Embedded Rust| L[embedded-rust Template]
    K -->|Alternative| M[Other Templates]
    L --> N[Initialize Project from Template]
    M --> N
    N --> O[Project Setup Complete]
    O --> P[Rust Toolchain Ready]
    P --> Q[Cross-Compilation Tools Loaded]
    Q --> R[Begin Embedded Development]
    R --> S[Write Rust Code]
    S --> T[Build for Target]
    T --> U[Test & Debug]
    U --> V{Changes?}
    V -->|Yes| S
    V -->|No| W[Deployment Ready]
    
    classDef startEnd stroke #4ade80,fill #f0fdf4
    classDef flakeConfig stroke #818cf8,fill #eef2ff
    classDef direnvConfig stroke #2dd4bf,fill #f0fdfa
    classDef template stroke #a78bfa,fill #f5f3ff
    classDef devWork stroke #fb923c,fill #fff7ed
    classDef workflow stroke #38bdf8,fill #f0f9ff
    
    class A,W startEnd
    class B,C,D flakeConfig
    class E,F,G,H direnvConfig
    class J,K,L,M,N template
    class O,P,Q devWork
    class R,S,T,U,V workflow
```

or use this

```nix
{ pkgs, ... }:
let
  mkprj = pkgs.writeShellApplication {
    name = "mkprj";
    runtimeInputs = [
      pkgs.nix
      pkgs.git
      pkgs.direnv
      pkgs.jq
    ];
    text = builtins.readFile [./mkprj.sh]; 
  };
in
{
  home.packages = with pkgs; [ mkprj ];
}
```
[mkprj](mkprj.sh)


work like this:)
```mermaid
---
config:
  layout: elk
---
flowchart TD
    A[Start: NixOS System] --> B[mkprj new rust-rp2040 foobar]
    B --> C[Begin Embedded Development]
    C --> D[Write Rust Code]
    D --> E[Build for Target]
    E --> F[Test & Debug]
    F --> G{Changes?}
    G -->|Yes| D
    G -->|No| H[Deployment Ready]
    
    classDef startEnd stroke #4ade80,fill #f0fdf4
    classDef flakeConfig stroke #818cf8,fill #eef2ff
    classDef direnvConfig stroke #2dd4bf,fill #f0fdfa
    classDef template stroke #a78bfa,fill #f5f3ff
    classDef devWork stroke #fb923c,fill #fff7ed
    classDef workflow stroke #38bdf8,fill #f0f9ff
    
    class A,G startEnd
    class C,D,E devWork
    class F,G,H workflow
```