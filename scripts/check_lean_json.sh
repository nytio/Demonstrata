#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $(basename "$0") <file.lean>" >&2
  exit 1
fi

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
target="$1"

cd "$repo_root"

if [[ ! -f "$target" ]]; then
  echo "Lean file not found: $target" >&2
  exit 1
fi

exec "${HOME}/.elan/bin/lake" lean "$target" -- --json
