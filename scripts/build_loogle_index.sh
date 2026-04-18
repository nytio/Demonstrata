#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
loogle_ws="$repo_root/.local-tools/loogle-mimate"
loogle_bin="$loogle_ws/.lake/build/bin/loogle"
default_module="${LOOGLE_LOCAL_MODULE:-Mathlib}"
index_dir="${LOOGLE_LOCAL_INDEX_DIR:-$repo_root/.local-tools/loogle-indexes}"
mathlib_index_file="${LOOGLE_LOCAL_MATHLIB_INDEX:-$repo_root/.local-tools/loogle-indexes/Mathlib.extra}"

usage() {
  cat <<EOF
Usage: $0 [--module MODULE] [--output FILE] [--force]

Builds and persists a local loogle index for the selected module.

Examples:
  $0
  $0 --module Biblioteca.Demonstrations.Demo_20260402_180809_weighted_binomial_sum
  $0 --output /tmp/mathlib.extra --force

The canonical Mathlib index in this repo is:
  $mathlib_index_file
EOF
}

module_name="$default_module"
output_file=""
force=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --module)
      shift
      if [[ $# -eq 0 ]]; then
        echo "Missing value for --module" >&2
        exit 2
      fi
      module_name="$1"
      ;;
    --output)
      shift
      if [[ $# -eq 0 ]]; then
        echo "Missing value for --output" >&2
        exit 2
      fi
      output_file="$1"
      ;;
    --force)
      force=1
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
  shift
done

if [[ ! -x "$loogle_bin" ]]; then
  "$repo_root/scripts/build_loogle_local.sh"
fi

module_stem="${module_name//./__}"
module_stem="${module_stem//\//__}"
if [[ -z "$output_file" ]]; then
  if [[ "$module_name" == "Mathlib" ]]; then
    output_file="$mathlib_index_file"
  else
    output_file="$index_dir/$module_stem.extra"
  fi
  mkdir -p "$(dirname "$output_file")"
else
  mkdir -p "$(dirname "$output_file")"
fi

if [[ -e "$output_file" ]]; then
  if [[ "$force" -eq 1 ]]; then
    rm -f "$output_file"
  else
    echo "Persisted loogle index already exists: $output_file" >&2
    echo "Use --force to rebuild it." >&2
    exit 0
  fi
fi

paths=("$repo_root/.lake/build/lib/lean")
while IFS= read -r -d '' pkg_dir; do
  pkg_path="$pkg_dir/.lake/build/lib/lean"
  if [[ -d "$pkg_path" ]]; then
    paths+=("$pkg_path")
  fi
done < <(find "$repo_root/.lake/packages" -mindepth 1 -maxdepth 1 -type d -print0 | sort -z)
paths+=("$loogle_ws/.lake/build/lib/lean")
paths+=("$("${HOME}/.elan/bin/lean" --print-prefix)/lib/lean")

args=()
for path in "${paths[@]}"; do
  args+=(--path "$path")
done
args+=(--module "$module_name" --write-index "$output_file")

"$loogle_bin" "${args[@]}"

echo "Persisted loogle index written to $output_file"
if [[ "$module_name" == "Mathlib" ]]; then
  echo "This repo reuses that exact Mathlib index path with --read-index."
  echo "Rebuild it only when the Mathlib library changes."
fi
