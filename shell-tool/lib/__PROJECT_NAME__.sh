#!/usr/bin/env bash
# Core functions for __PROJECT_NAME__. Sourced, never executed directly.

# greet prints a hello message for the given name, defaulting to "world".
greet() {
    local name="${1:-world}"
    printf 'hello, %s\n' "$name"
}
