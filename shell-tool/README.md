# __PROJECT_NAME__

## Layout

- `lib/__PROJECT_NAME__.sh` — functions, sourced only, never executed directly
- `__PROJECT_NAME__` — thin entrypoint, sources the lib and calls into it
- `tests/` — bats tests

## Dev shell

```sh
nix develop
```

## Test, lint, run

```sh
just test   # bats tests/
just lint   # shellcheck
just doc    # dumps doc-comments above each function in lib/
just run [args]
```

## License

GPLv3, see [LICENSE](./LICENSE).
