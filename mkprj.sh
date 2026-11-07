#!/usr/bin/env bash
# shellcheck shell=bash
# mkprj: scaffold projects from github.com/slaxor/templates.
set -uo pipefail

repo="${repo-git+https://github.com/slaxor/templates}"
params_file="mkprj.params"
declare -A overrides=() answers=()

# mkprj_usage prints the top-level usage summary.
mkprj_usage() {
  cat <<'EOF'
usage: mkprj <command> [args]

commands:
  new [--refresh] [--set KEY=VALUE]... <template> <dest-path>
                                           scaffold a new project at dest-path
  list [--refresh]                         list available template names
  help                                      show this message

Templates may ship a mkprj.params file with lines of KEY|default|prompt.
mkprj asks for each value (or takes the default when stdin is not a
terminal), replaces __KEY__ in contents and filenames, then deletes the
file. Every answer is also available as __KEY_SLUG__ (DNS-safe) and
__KEY_DOMAIN__ (underscores become dots, leading www. dropped) and
__KEY_STEM__ (that domain without its TLD), and defaults may use
earlier answers. __PROJECT_DIR__ is the unsanitized
directory name. --set KEY=VALUE answers up front.

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

# mkprj_sed_escape escapes a value for use as a sed replacement with |
# as delimiter, so URLs and paths survive.
mkprj_sed_escape() {
  printf '%s' "$1" | sed -e 's/[\\&|]/\\&/g'
}

# mkprj_substitute rewrites __KEY__ with value in file contents and
# filenames under the given directory, in place.
mkprj_substitute() {
  local dir="$1" key="$2" value="$3"
  local placeholder="__${key}__" escaped
  escaped="$(mkprj_sed_escape "${value}")"
  (
    cd "${dir}" || exit 1
    { grep -rlZ -- "${placeholder}" . || [ $? -eq 1 ]; } | xargs -0 -r sed -i "s|${placeholder}|${escaped}|g"
    find . -depth -name "*${placeholder}*" | while read -r p; do
      mv "${p}" "${p//${placeholder}/${value}}"
    done
  )
}

# mkprj_ask prints the value for key: a --set override, else the answer
# to an interactive prompt, else the default when stdin is no terminal.
mkprj_ask() {
  local key="$1" default="$2" prompt="$3" answer
  if [ -n "${overrides[${key}]+set}" ]; then
    printf '%s' "${overrides[${key}]}"
    return
  fi
  if [ ! -t 0 ]; then
    printf '%s' "${default}"
    return
  fi
  read -r -p "${prompt} [${default}]: " answer
  printf '%s' "${answer:-${default}}"
}

# mkprj_check_overrides fails on --set keys the template does not know,
# so typos don't vanish silently.
mkprj_check_overrides() {
  local known="$1" key status=0
  for key in "${!overrides[@]}"; do
    if ! printf '%s\n' "${known}" | grep -qx -- "${key}"; then
      printf 'mkprj: template has no parameter "%s"\n' "${key}" >&2
      status=1
    fi
  done
  return "${status}"
}

# mkprj_slug turns a value into a DNS-1123 label: lower case, runs of
# anything else become a single hyphen, no hyphen at either end.
mkprj_slug() {
  printf '%s' "$1" | tr '[:upper:]' '[:lower:]' | sed -E -e 's/[^a-z0-9]+/-/g' -e 's/^-+|-+$//g'
}

# mkprj_domain reads a value as a domain written with underscores
# (www_slaxor_de -> slaxor.de); a leading www. is dropped.
mkprj_domain() {
  printf '%s' "$1" | tr '[:upper:]' '[:lower:]' | tr '_' '.' | sed -e 's/^www\.//'
}

# mkprj_stem is mkprj_domain without the TLD (www_slaxor_de -> slaxor).
mkprj_stem() {
  mkprj_domain "$1" | sed -e 's/\.[^.]*$//'
}

# mkprj_record stores an answer as __KEY__ plus its __KEY_SLUG__,
# __KEY_DOMAIN__ and __KEY_STEM__ variants.
mkprj_record() {
  answers["$1"]="$2"
  answers["$1_SLUG"]="$(mkprj_slug "$2")"
  answers["$1_DOMAIN"]="$(mkprj_domain "$2")"
  answers["$1_STEM"]="$(mkprj_stem "$2")"
}

# mkprj_expand replaces placeholders of answers given so far in text.
mkprj_expand() {
  local text="$1" key
  for key in "${!answers[@]}"; do
    text="${text//__${key}__/${answers[${key}]}}"
  done
  printf '%s' "${text}"
}

# mkprj_params asks for the parameters in the template's mkprj.params
# and removes the file. Defaults may refer to earlier answers.
mkprj_params() {
  local dir="$1" file="$1/${params_file}" lines=() line key default prompt keys=""
  if [ ! -f "${file}" ]; then
    mkprj_check_overrides ""
    return
  fi
  mapfile -t lines <"${file}"
  rm "${file}"

  for line in "${lines[@]}"; do
    IFS='|' read -r key default prompt <<<"${line}"
    keys+="${key}"$'\n'
  done
  mkprj_check_overrides "${keys}" || return 1

  for line in "${lines[@]}"; do
    IFS='|' read -r key default prompt <<<"${line}"
    mkprj_record "${key}" "$(mkprj_ask "${key}" "$(mkprj_expand "${default}")" "${prompt}")"
  done
}

# mkprj_apply substitutes every recorded answer under dir.
mkprj_apply() {
  local dir="$1" key
  for key in "${!answers[@]}"; do
    mkprj_substitute "${dir}" "${key}" "${answers[${key}]}"
  done
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
  while [ $# -gt 0 ]; do
    case "$1" in
    --refresh) refresh_flag=(--refresh) ;;
    --set)
      if [[ "${2:-}" != *=* ]]; then
        printf 'mkprj: --set needs KEY=VALUE\n' >&2
        return 1
      fi
      overrides["${2%%=*}"]="${2#*=}"
      shift
      ;;
    *) args+=("$1") ;;
    esac
    shift
  done

  local template="${args[0]:-}" dest="${args[1]:-}"

  if [ -z "${template}" ] || [ -z "${dest}" ]; then
    printf 'usage: mkprj new [--refresh] [--set KEY=VALUE]... <template> <dest-path>\n' >&2
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

  mkprj_record PROJECT_NAME "${name}"
  mkprj_record PROJECT_DIR "$(basename "${dest}")"
  if ! mkprj_params "${dest}"; then
    rm -rf -- "${dest}"
    return 1
  fi
  mkprj_apply "${dest}"
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
