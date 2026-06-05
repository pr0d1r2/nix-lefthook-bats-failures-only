#!/usr/bin/env bats

setup() {
    load "${BATS_LIB_PATH}/bats-support/load.bash"
    load "${BATS_LIB_PATH}/bats-assert/load.bash"

    PROJECT_ROOT="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
}

@test "glob only matches .bats files" {
    run bash -c "grep 'glob:' '$PROJECT_ROOT/lefthook-remote.yml'"
    assert_success
    assert_output --partial '"*.bats"'
    refute_output --partial '.sh'
}
