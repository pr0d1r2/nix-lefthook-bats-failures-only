# SPEC — nix-lefthook-bats-failures-only

## §G Goal

Lefthook-compatible failures-only runner for bats. Wraps `bats` with TAP
output and prints only `not ok` lines, their `#` diagnostic context, and a
one-line summary — passing tests are silent. Reduces pre-push noise without
hiding any failure: every argument is forwarded to `bats` and the wrapper
exits with bats' exit code. Nix flake pkg. Opensource-safe: zero
credentials, zero local paths, zero private refs.

## §C Constraints

- C1: Pure bash — the wrapper is a single sourced script, no Python/Ruby/etc
- C2: Sourced by `writeShellApplication` — no shebang, no `set` line; the
  builder supplies `set -euo pipefail` and runtime `PATH`
- C3: Nix flake — `writeShellApplication` pkg; devShells `default`/`ci`
  built inline with `pkgs.mkShell` (no `nix-dev-shell-agentic`)
- C4: Flake inputs are `nixpkgs` (via `nixpkgs-lock`) plus `flake = false`
  `-src` leaves only — flattened, no heavy flake inputs
- C5: MIT license
- C6: Multi-platform: `aarch64-darwin`, `x86_64-darwin`, `x86_64-linux`,
  `aarch64-linux`
- C7: Detached from parent project — no credential leaks, no hardcoded local
  paths, no private repo refs
- C8: Timeout config via env var — no config files beyond baseline
- C9: GNU coreutils — portable across macOS and Linux

## §I Interfaces

- I.cli: `lefthook-bats-failures-only <files...>` — forwards args to
  `bats --formatter tap`, prints failures-only output, exits with bats' rc
- I.env: `LEFTHOOK_BATS_FAILURES_ONLY_TIMEOUT` (seconds, default `120`) —
  consumed by `lefthook-remote.yml` to wrap the run in `timeout`
- I.remote: `lefthook-remote.yml` — `pre-push` command `bats-failures-only`,
  `glob: "*.bats"`, runs the binary over `{push_files}`; consumers add it as
  a lefthook remote
- I.flake: `packages.${system}.default` — the `lefthook-bats-failures-only`
  pkg; `runtimeInputs` is `bats.withLibraries` (bats-support, bats-assert,
  bats-file) so suites that `load` those helpers run inside the hook
- I.devshell: `devShells.${system}.default` + `.#ci` — `mkShell` providing
  the pkg, `bats.withLibraries`, lefthook, nix, git, parallel, coreutils,
  and all linter wrappers; `ci` aliases `default`
- I.ci: `.github/workflows/ci.yml` — linux + macos via
  `nix-lefthook-ci-action` (nix build + lefthook pre-commit + pre-push);
  `.github/workflows/update-pins.yml` refreshes input pins

## §V Invariants

- V1: Passing tests produce zero output lines — only the summary is printed
- V2: A failing test prints its `not ok` line plus every following `#`
  diagnostic line, until the next `ok`/`not ok` resets the printing state
- V3: Exit code equals bats' exit code — failures are never swallowed
- V4: Summary line `N tests, M failures` is always printed, where `N` comes
  from the TAP plan (`1..N`) and `M` counts `not ok` lines
- V5: When bats exits non-zero without producing TAP (`total == 0` and
  `failed == 0`), the raw captured output is echoed on stderr as a fallback
- V6: The TAP capture file is created with `mktemp` and removed by an `EXIT`
  trap — no temp leakage
- V7: `lefthook-remote.yml` glob is `*.bats` only — never matches `.sh`,
  so the hook only feeds bats files bats can execute
- V8: The hook run is bounded by `timeout` using
  `LEFTHOOK_BATS_FAILURES_ONLY_TIMEOUT` (default `120`)
- V9: The pkg's `runtimeInputs` uses `bats.withLibraries`, not plain `bats`,
  so suites loading bats-support/bats-assert/bats-file succeed under the hook
- V10: `dev.sh` exports `BATS_LIB_PATH` (substituted at build time) and runs
  `lefthook install` when `.git/hooks/pre-commit` is absent
- V11: `nix flake check` is green and `nix flake show` lists
  `packages.<system>.default = lefthook-bats-failures-only`; `flake.lock`
  has no `nix-dev-shell-agentic` subtree
- V12: No credentials, secrets, tokens, API keys, or private paths in any
  tracked file
- V13: No hardcoded local filesystem paths (enforced by
  `nix-lefthook-git-no-local-paths`)
- V14: CI runs lefthook pre-commit and pre-push on linux + macos
- V15: All linters pass: shellcheck, shfmt, nixfmt, statix, deadnix,
  yamllint, typos, editorconfig-checker, bats-parse, file-size-check,
  trailing-whitespace, missing-final-newline, git-conflict-markers,
  git-no-local-paths, nix-no-embedded-shell

## §T Tasks

## §B Bugs

| id | date | cause | fix |
| --- | --- | --- | --- |
| B1 | 2026-08-13 | Pinned actions fragment passed a workflow regex as a string to Nix’s source filter. | Removed incompatible fragment; guardrails still validate workflows. |
| B2 | 2026-08-13 | Tracked lefthook config retained commands from the removed actions fragment. | Regenerated lefthook.yml from active fragments. |
| B3 | 2026-08-14 | Flake omitted actions although the canonical assembler includes it, producing a different lefthook.yml. | Restored actions and canonical actionlint commands. |
| B4 | 2026-08-14 | Pinned actions fragment passed a scalar where the source filter requires a list. | Removed incompatible fragment and generated commands. |
| B5 | 2026-08-14 | Canonical actions commands were absent while the pinned check used an incompatible scalar regex. | Restored commands and added a local actionlint wrapper. |
| B6 | 2026-08-14 | Six selected fragments omitted canonical actions, causing guardrails fidelity mismatch. | Added actions and regenerated lefthook.yml. |
| B7 | 2026-08-14 | Pinned actionlint passed scalar pathPrefix to newer sourceByRegex. | Bypassed only that helper and added equivalent local validation. |
| B8 | 2026-08-14 | SPEC.md exceeded 8 KiB, and actionlint shell embedded in flake.nix violated nix-no-embedded-shell. | Shortened history and moved the check to scripts/actionlint-check.sh. |

| id | status | task | cites |
| --- | --- | --- | --- |
| T1 | x | TAP filter wrapper: failures-only output + summary | C1,C2,V1,V2,V4,I.cli |
| T2 | x | exit with bats' rc; fallback raw output on non-TAP failure | V3,V5,I.cli |
| T3 | x | mktemp capture file + EXIT trap cleanup | V6 |
| T4 | x | Nix flake pkg via `writeShellApplication` | C3,C4,I.flake |
| T5 | x | pkg `runtimeInputs` uses `bats.withLibraries` (support/assert/file) | V9,I.flake |
| T6 | x | inline `mkShell` devShells `default`/`ci` with linter wrappers | C3,I.devshell |
| T7 | x | `dev.sh` — BATS_LIB_PATH export + auto lefthook install | V10 |
| T8 | x | `lefthook-remote.yml` pre-push hook, glob `*.bats` | C4,V7,I.remote |
| T9 | x | timeout wrap via `LEFTHOOK_BATS_FAILURES_ONLY_TIMEOUT` | C8,V8,I.env |
| T10 | x | unit tests: failures-only behavior (pass/fail/mixed) | V1,V2,V3,V4 |
| T11 | x | unit tests: dev.sh BATS_LIB_PATH + lefthook install | V10 |
| T12 | x | unit tests: lefthook-remote glob excludes `.sh` | V7 |
| T13 | x | GitHub Actions CI via nix-lefthook-ci-action: linux + macos | V14,I.ci |
| T14 | x | linter suite via lefthook remotes | V15 |
| T15 | x | flatten flake: drop `nix-dev-shell-agentic`, inline wrappers + mkShell | C3,C4,V11 |
| T16 | x | opensource audit: no credentials/local-paths/private-refs | V12,V13,C7 |
