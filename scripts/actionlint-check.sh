#!/usr/bin/env bash
set -euo pipefail

mapfile -t workflows < <(find .github/workflows -type f \( -name '*.yml' -o -name '*.yaml' \) | sort)
if [ "${#workflows[@]}" -gt 0 ]; then actionlint "${workflows[@]}"; fi
