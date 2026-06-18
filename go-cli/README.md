# __PROJECT_NAME__

## Layout

- `core/` — library package, public API
- `cmd/__PROJECT_NAME__/` — thin binary, consumes `core`'s public API only

## Dev shell

```sh
nix develop
go mod tidy   # generates go.sum on first use
```

## Build & test

```sh
go test ./...
just build
just doc   # go doc -all ./core
```

## License

GPLv3, see [LICENSE](./LICENSE).
