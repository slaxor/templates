# __PROJECT_NAME__

## Layout

- `core/router.go` — route table and middleware (chi + request logging)
- `core/*_handler.go` — one file per handler, public API
- `cmd/__PROJECT_NAME__/` — thin binary, wires up `core.NewRouter()` and listens

Routing is [chi](https://github.com/go-chi/chi); request logging is its bundled `middleware.Logger`.

## Dev shell

```sh
nix develop
go mod tidy   # generates go.sum on first use
```

## Build & test

```sh
go test ./...
just build
just run    # listens on :8080
just doc    # go doc -all ./core
```

```sh
curl localhost:8080/greet/alice
```

## License

GPLv3, see [LICENSE](./LICENSE).
