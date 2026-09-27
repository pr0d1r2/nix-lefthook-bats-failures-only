#!/usr/bin/env bats

setup() {
    load "${BATS_LIB_PATH}/bats-support/load.bash"
    load "${BATS_LIB_PATH}/bats-assert/load.bash"

    TMP="$BATS_TEST_TMPDIR"

    # The standard's dev shell does not carry this repo's own package, so
    # exercise the working-tree script under the same strict mode
    # writeShellApplication gives packages.default.
    SCRIPT="$BATS_TEST_DIRNAME/../../lefthook-bats-failures-only.sh"
    mkdir -p "$TMP/bin"
    printf '#!/usr/bin/env bash\nexec bash -euo pipefail "%s" "$@"\n' \
        "$SCRIPT" >"$TMP/bin/lefthook-bats-failures-only"
    chmod +x "$TMP/bin/lefthook-bats-failures-only"
    export PATH="$TMP/bin:$PATH"
}

@test "all-passing suite prints only summary" {
    cat > "$TMP/pass.bats" <<'BATS'
#!/usr/bin/env bats
@test "ok1" { true; }
@test "ok2" { true; }
BATS
    run lefthook-bats-failures-only "$TMP/pass.bats"
    assert_success
    assert_output --partial "2 tests, 0 failures"
    refute_output --partial "not ok"
}

@test "failing test shows not-ok line and context" {
    cat > "$TMP/fail.bats" <<'BATS'
#!/usr/bin/env bats
@test "will fail" { false; }
BATS
    run lefthook-bats-failures-only "$TMP/fail.bats"
    assert_failure
    assert_output --partial "not ok"
    assert_output --partial "1 tests, 1 failures"
}

@test "passing lines are suppressed" {
    cat > "$TMP/mix.bats" <<'BATS'
#!/usr/bin/env bats
@test "pass" { true; }
@test "fail" { false; }
BATS
    run lefthook-bats-failures-only "$TMP/mix.bats"
    assert_failure
    assert_output --partial "not ok"
    refute_output --partial "ok 1"
}
