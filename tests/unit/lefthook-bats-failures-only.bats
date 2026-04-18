#!/usr/bin/env bats

setup() {
    load "${BATS_LIB_PATH}/bats-support/load.bash"
    load "${BATS_LIB_PATH}/bats-assert/load.bash"

    TMP="$BATS_TEST_TMPDIR"
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
