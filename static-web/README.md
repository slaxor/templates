# __PROJECT_NAME__

Static site for https://www.__DOMAIN__, built with [Zola](https://www.getzola.org)
and served by [static-web-server](https://static-web-server.net) on Kubernetes.

## Layout

- `zola.toml` — site config, `[extra]` holds author and fediverse links
- `content/` — markdown; `notes/` is a dated section
- `templates/` — Tera 2 templates, shared bits in `partials/`
- `static/` — copied verbatim, `style.css` lives here
- `k8s.yaml` — namespace `__NAMESPACE__`, deployment, service, cert-manager
  certificate and Traefik route; `__DOMAIN__` redirects to `www.__DOMAIN__`
- `Containerfile` — builds the site with Zola, serves it with static-web-server
- `.gitea/workflows/image.yaml` — builds and pushes the image on every push
  to master

The flake follows nixos-unstable on purpose: Zola 0.23 switched to Tera 2,
and the templates use its syntax.

## Fediverse

With `fedi_profile` set, pages carry a `rel="me"` link for profile
verification. With `fedi_feed` set, the start page lists the latest posts,
fetched at build time. An unreachable feed does not break the build.

## Dev shell

```sh
nix develop
```

## Build & preview

```sh
just serve   # live preview including drafts
just build   # renders to public/
```

## Deploy

Pushing to master makes the Gitea runner build and push `__IMAGE__`. It
needs two repository secrets: `REGISTRY_USER` and `REGISTRY_TOKEN` (an
access token with package write scope). Then roll it out:

```sh
just rollout  # apply k8s.yaml, restart, wait
```

Without CI, `just deploy` does build, push and rollout locally
(`OCI=docker just deploy` if podman is not your container tool).

The image is built in a container rather than with nix on purpose: the
fediverse feed is fetched at build time, which the nix sandbox would block.

## License

[CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/), see [LICENSE](./LICENSE).
