# SPEC — nix-lefthook-bats-failures-only

## §G GOAL

Lefthook pre-push hook that runs bats tests and only prints failures + summary. Reduces push output noise — passing tests are silent, only failures and their diagnostic lines are shown.

## §C CONSTRAINTS

- C1: Nix flake, single package (`lefthook-bats-failures-only`)
- C1a: Flake inputs are nixpkgs (via `nixpkgs-lock`) + `flake = false` `-src` leaves only — no heavy flake inputs (no `nix-dev-shell-agentic`); devShells `default`/`ci` built inline with `pkgs.mkShell` and inline lefthook wrappers
- C2: Shell script sourced by `writeShellApplication` — no shebang, no `set` needed
- C3: GNU coreutils — portable macOS + Linux
- C4: Lefthook remote — consumers add `lefthook-remote.yml` to their `lefthook.yml`
- C5: Passes all arguments to `bats --formatter tap`, filters TAP output
- C6: Only shows `not ok` lines and their `#` diagnostic lines
- C7: Prints summary: `N tests, M failures`
- C8: Falls back to raw output when bats exits non-zero without producing TAP

## §I INTERFACES

- I.run: `lefthook-bats-failures-only <files>` — run bats on files, print failures only
- I.remote: `lefthook-remote.yml` — pre-push hook definition
- I.env.TIMEOUT: `LEFTHOOK_BATS_FAILURES_ONLY_TIMEOUT` — timeout in seconds (default: 120)

## §V INVARIANTS

- V1: Passing tests produce zero output lines (only summary)
- V2: Failed tests show `not ok` line + all `#` diagnostic lines
- V3: Exit code matches bats exit code — never swallows failures
- V4: Glob must only match files bats can execute (`.bats` files)
- V5: When bats exits non-zero without TAP output, raw output is shown on stderr
- V6: `nix flake check` green and `nix flake show` lists `packages.<sys>.default = lefthook-bats-failures-only`; flake.lock has no `nix-dev-shell-agentic` subtree

## §T TASKS

| id | st | task | cites |
|----|-----|------|-------|
| T1 | x | TAP filter script: failures-only output | C5,C6,C7,V1,V2 |
| T2 | x | Fallback raw output on non-TAP failure | C8,V5 |
| T3 | x | flake.nix: package + devShell | C1,C2,C3 |
| T4 | x | lefthook-remote.yml: pre-push hook | C4 |
| T5 | x | Fix glob to exclude `.sh` files | V4 |
| T6 | x | Flatten flake: drop `nix-dev-shell-agentic`, inline `-src` wrappers + mkShell devShells | C1a,V6 |
