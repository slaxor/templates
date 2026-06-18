# __PROJECT_NAME__

## Layout

- `lib.typ` — reusable functions and styles
- `main.typ` — the actual document, imports from `lib.typ`
- `fonts/` — project fonts, committed for reproducible builds

Currently uses the bundled "New Computer Modern" font, so `fonts/` is empty
and `--font-path` is a no-op until you add a custom font there.

## Dev shell

```sh
nix develop
```

## Build & preview

```sh
just build   # compiles to __PROJECT_NAME__.pdf
just watch   # live preview, recompiles on save
```

## License

GPLv3, see [LICENSE](./LICENSE).
