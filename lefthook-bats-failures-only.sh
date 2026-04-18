# shellcheck shell=bash
# Wrapper: run bats with TAP output and only print failures + summary.
# Passes all arguments to bats. Exits with bats' exit code.
# NOTE: sourced by writeShellApplication — no shebang or set needed.

tap_output=$(mktemp)
trap 'rm -f "$tap_output"' EXIT

bats_rc=0
bats --formatter tap "$@" >"$tap_output" 2>&1 || bats_rc=$?

total=0
failed=0
printing=0

while IFS= read -r line; do
    case "$line" in
        [0-9]*'..'[0-9]*)
            total="${line#*..}"
            ;;
        'not ok '*)
            printing=1
            failed=$((failed + 1))
            echo "$line"
            ;;
        'ok '*)
            printing=0
            ;;
        '# '*)
            if [ "$printing" -eq 1 ]; then
                echo "$line"
            fi
            ;;
    esac
done <"$tap_output"

echo "$total tests, $failed failures"

if [ "$bats_rc" -ne 0 ] && [ "$total" -eq 0 ] && [ "$failed" -eq 0 ]; then
    echo "lefthook-bats-failures-only: bats exited $bats_rc without producing TAP; raw output follows:" >&2
    cat "$tap_output" >&2
fi

exit "$bats_rc"
