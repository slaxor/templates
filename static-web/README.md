# __PROJECT_NAME__

A small personal page for https://www.__DOMAIN__: name, links and the
latest fediverse posts. Built with [Zola](https://www.getzola.org), served
by [static-web-server](https://static-web-server.net) on Kubernetes.

## Layout

- `zola.toml` — site config; `[extra]` holds the fediverse settings, and
  each `[[extra.links]]` block adds a link under the title
- `content/` — markdown; the start page only carries the title
- `templates/` — Tera 2 templates, shared bits in `partials/`
- `static/` — copied verbatim, `style.css` lives here
- `k8s.yaml` — namespace `__NAMESPACE__`, deployment, service, cert-manager
  certificate, Traefik route (`__DOMAIN__` redirects to `www.__DOMAIN__`)
  and a `deployer` service account allowed to restart `web` only
- `.gitea/workflows/image.yaml` — builds, pushes and restarts on every push
  to master

The flake follows nixos-unstable on purpose: Zola 0.23 switched to Tera 2,
and the templates use its syntax.

## Fediverse

The start page lists the latest posts from `fedi_feed`, fetched at build
time and shown in full. An unreachable feed does not break the build.
With `fedi_profile` set, the page carries a `rel="me"` link for profile
verification.

## Dev shell

```sh
nix develop
```

## Build & deploy

```sh
just serve    # live preview
just run      # build the image locally, start it on http://localhost:8080
just publish  # build the image, push it as __IMAGE__
just rollout  # apply k8s.yaml, restart, wait
just deploy   # publish and rollout
```

There is one way to build the image: `crane` appends `public/` as a layer
to the static-web-server base image, no container daemon involved.
`publish` pushes it, `run` writes it to `image.tar` and starts it with
podman. Log in once with `crane auth login`.

The site is built outside the nix sandbox on purpose: the fediverse feed
is fetched at build time, which the sandbox would block.

## CI

On every push to master, the Gitea runner labelled `nix` runs
`just publish` and `just restart` inside the dev shell. It needs:

- variable `REGISTRY_USER`
- secret `REGISTRY_TOKEN`: access token with package write scope
- secret `KUBECONFIG`: kubeconfig of the `deployer` service account

After the first `just rollout`, build that kubeconfig on a machine with
admin access to the cluster:

```sh
ns=__NAMESPACE__
out=deployer.kubeconfig
secret_field() { kubectl -n "$ns" get secret deployer-token -o "jsonpath={.data.$1}" | base64 -d; }
token="$(secret_field token)"
secret_field 'ca\.crt' > ca.crt
kubectl --kubeconfig "$out" config set-cluster k3s --server=https://127.0.0.1:6443 --certificate-authority=ca.crt --embed-certs=true
kubectl --kubeconfig "$out" config set-credentials deployer --token="$token"
kubectl --kubeconfig "$out" config set-context deployer --cluster=k3s --user=deployer --namespace="$ns"
kubectl --kubeconfig "$out" config use-context deployer
rm ca.crt
```

Paste the contents of `deployer.kubeconfig` into the `KUBECONFIG` secret,
then delete the file. `127.0.0.1` assumes the runner runs on the k3s host.

## License

[CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/), see [LICENSE](./LICENSE).
