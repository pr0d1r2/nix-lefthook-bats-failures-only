# nix-lefthook-bats-failures-only

[![CI](https://github.com/pr0d1r2/nix-lefthook-bats-failures-only/actions/workflows/ci.yml/badge.svg)](https://github.com/pr0d1r2/nix-lefthook-bats-failures-only/actions/workflows/ci.yml)

> This code is LLM-generated and validated through an automated integration process using [lefthook](https://github.com/evilmartians/lefthook) git hooks, [bats](https://github.com/bats-core/bats-core) unit tests, and GitHub Actions CI.

Lefthook-compatible [Bats](https://github.com/bats-core/bats-core) failures-only runner, packaged as a Nix flake.

Runs bats with TAP output and prints only failures plus a summary line. Passes all arguments through to bats. Exits with bats' exit code.

## Usage

### Option A: Lefthook remote (recommended)

Add to your `lefthook.yml` — no flake input needed, just the wrapper binary in your devShell:

```yaml
remotes:
  - git_url: https://github.com/pr0d1r2/nix-lefthook-bats-failures-only
    ref: main
    configs:
      - lefthook-remote.yml
```

### Option B: Flake input

Add as a flake input:

```nix
inputs.nix-lefthook-bats-failures-only = {
  url = "github:pr0d1r2/nix-lefthook-bats-failures-only";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

Add to your devShell:

```nix
nix-lefthook-bats-failures-only.packages.${pkgs.stdenv.hostPlatform.system}.default
```

### Configuring timeout

The default timeout is 120 seconds. Override per-repo via environment variable:

```bash
export LEFTHOOK_BATS_FAILURES_ONLY_TIMEOUT=60
```

## Development

The repo includes an `.envrc` for [direnv](https://direnv.net/) — entering the directory automatically loads the devShell with all dependencies:

```bash
cd nix-lefthook-bats-failures-only  # direnv loads the flake
bats tests/unit/
```

If not using direnv, enter the shell manually:

```bash
nix develop
bats tests/unit/
```

## License

MIT
