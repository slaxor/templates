#!/usr/bin/env bash
# Shell functions for scaffolding new projects from codeberg.org/slaxor/templates.

# proj-new generates a new project from a template into dest, anywhere on disk.
proj-new() {
  local template="$1"
  local dest="$2"
  local repo="git+https://codeberg.org/slaxor/templates"

  if [ -z "${template}" ] || [ -z "${dest}" ]; then
    printf 'usage: proj-new <template> <dest-path>\n' >&2
    return 1
  fi
  if [ -e "${dest}" ]; then
    printf 'proj-new: %s already exists\n' "${dest}" >&2
    return 1
  fi

  nix flake new -t "${repo}#${template}" "${dest}" || return 1

  local name
  name="$(basename "${dest}" | tr '-' '_')"
  if [ "${name}" != "$(basename "${dest}")" ]; then
    printf 'proj-new: using "%s" as the project identifier (hyphens become underscores)\n' "${name}" >&2
  fi

  (
    cd "${dest}" || exit 1
    grep -rlZ __PROJECT_NAME__ . | xargs -0 sed -i "s/__PROJECT_NAME__/${name}/g"
    find . -depth -name '*__PROJECT_NAME__*' | while read -r p; do
      mv "${p}" "${p//__PROJECT_NAME__/${name}}"
    done
    git init -q

    printf 'use flake\n' >.envrc
    git add .

    if ! command -v direnv >/dev/null; then
      printf 'proj-new: direnv not on PATH, skipping allow\n' >&2
      exit 0
    fi
    direnv allow .
    direnv status | grep -i allow
  )
}
