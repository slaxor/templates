#!/usr/bin/env bash
# shellcheck shell=bash
# mkprj: scaffold projects from github.com/slaxor/templates.
set -xuo pipefail

repo="${repo-git+https://github.com/slaxor/templates}"

# mkprj_usage prints the top-level usage summary.
mkprj_usage() {
  cat <<'EOF'
usage: mkprj <command> [args]

commands:
  new [--refresh] <template> <dest-path>   scaffold a new project at dest-path
  list [--refresh]                         list available template names
  help                                      show this message

nix caches the resolved revision of a remote flake ref, so after pushing
new templates to the repo, mkprj may not see them until the cache expires.
Pass --refresh to force a re-fetch.
EOF
}

# mkprj_list queries the templates flake and prints one template name per
# line. Pass --refresh to bypass nix's cached revision of the repo (nix
# otherwise won't notice newly pushed templates until the cache expires).
mkprj_list() {
  local refresh_flag=()
  [ "${1:-}" = "--refresh" ] && refresh_flag=(--refresh)

  nix eval "${refresh_flag[@]}" "${repo}#templates" --apply builtins.attrNames --json | jq -r '.[]'
}

# mkprj_sanitize converts a destination path's basename into an
# identifier-safe project name (hyphens become underscores).
mkprj_sanitize() {
  basename "$1" | tr '-' '_'
}

# mkprj_substitute rewrites __PROJECT_NAME__ in file contents and
# filenames under the given directory, in place.
mkprj_substitute() {
  local dir="$1" name="$2"
  (
    cd "${dir}" || exit 1
    grep -rlZ __PROJECT_NAME__ . | xargs -0 sed -i "s/__PROJECT_NAME__/${name}/g"
    find . -depth -name '*__PROJECT_NAME__*' | while read -r p; do
      mv "${p}" "${p//__PROJECT_NAME__/${name}}"
    done
  )
}

# mkprj_git_init stages a fresh git repo, writes .envrc (never shipped by
# the template itself, since nix's flake fetcher excludes .envrc on purpose),
# and allows direnv if it's available.
mkprj_git_init() {
  local dir="$1"
  (
    cd "${dir}" || exit 1
    git init -q
    printf 'use flake\n' >.envrc
    git add .

    if ! command -v direnv >/dev/null; then
      printf 'mkprj: direnv not on PATH, skipping allow\n' >&2
      exit 0
    fi
    direnv allow .
    direnv status | grep -i allow
  )
}

# mkprj_new scaffolds template into dest, substituting the project name
# and preparing git + direnv. Accepts --refresh anywhere in the args to
# force a re-fetch of the templates repo (see mkprj_list).
mkprj_new() {
  local refresh_flag=() args=()
  for arg in "$@"; do
    if [ "${arg}" = "--refresh" ]; then
      refresh_flag=(--refresh)
    else
      args+=("${arg}")
    fi
  done

  local template="${args[0]:-}" dest="${args[1]:-}"

  if [ -z "${template}" ] || [ -z "${dest}" ]; then
    printf 'usage: mkprj new [--refresh] <template> <dest-path>\n' >&2
    return 1
  fi
  if [ -e "${dest}" ]; then
    printf 'mkprj: %s already exists\n' "${dest}" >&2
    return 1
  fi

  nix flake new "${refresh_flag[@]}" -t "${repo}#${template}" "${dest}" || return 1

  local name
  name="$(mkprj_sanitize "${dest}")"
  if [ "${name}" != "$(basename "${dest}")" ]; then
    printf 'mkprj: using "%s" as the project identifier (hyphens become underscores)\n' "${name}" >&2
  fi

  mkprj_substitute "${dest}" "${name}"
  mkprj_git_init "${dest}"
}

cmd="${1:-help}"
case "${cmd}" in
new)
  shift
  mkprj_new "$@"
  ;;
list)
  shift
  mkprj_list "$@"
  ;;
help | -h | --help) mkprj_usage ;;
*)
  printf 'mkprj: unknown command "%s"\n\n' "${cmd}" >&2
  mkprj_usage >&2
  exit 1
  ;;
esac
