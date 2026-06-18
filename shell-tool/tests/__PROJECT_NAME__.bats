#!/usr/bin/env bats

setup() {
    load_dir="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
    source "${load_dir}/lib/__PROJECT_NAME__.sh"
}

@test "greet with a name" {
    run greet "alice"
    [ "$status" -eq 0 ]
    [ "$output" = "hello, alice" ]
}

@test "greet falls back to world when no name given" {
    run greet
    [ "$status" -eq 0 ]
    [ "$output" = "hello, world" ]
}
