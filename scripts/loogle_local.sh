#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
loogle_ws="$repo_root/.local-tools/loogle-mimate"
loogle_bin="$loogle_ws/.lake/build/bin/loogle"
default_module="${LOOGLE_LOCAL_MODULE:-Mathlib}"
index_dir="${LOOGLE_LOCAL_INDEX_DIR:-$repo_root/.local-tools/loogle-indexes}"
mathlib_index_file="${LOOGLE_LOCAL_MATHLIB_INDEX:-$repo_root/.local-tools/loogle-indexes/Mathlib.extra}"
disable_persisted_index="${LOOGLE_LOCAL_DISABLE_PERSISTED_INDEX:-0}"

if [[ ! -x "$loogle_bin" ]]; then
  "$repo_root/scripts/build_loogle_local.sh"
fi

has_module=0
explicit_module=""
has_read_index=0
has_write_index=0
prev=""
for arg in "$@"; do
  case "$prev" in
    --module)
      has_module=1
      explicit_module="$arg"
      ;;
  esac
  case "$arg" in
    --read-index)
      has_read_index=1
      ;;
    --write-index)
      has_write_index=1
      ;;
  esac
  prev="$arg"
done

target_module="${explicit_module:-$default_module}"
index_stem="${target_module//./__}"
index_stem="${index_stem//\//__}"
if [[ "$target_module" == "Mathlib" ]]; then
  default_index_file="$mathlib_index_file"
else
  default_index_file="$index_dir/$index_stem.extra"
fi
index_file="${LOOGLE_LOCAL_INDEX_FILE:-$default_index_file}"

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
if [[ "$has_module" -eq 0 ]]; then
  args+=(--module "$default_module")
fi
if [[ "$disable_persisted_index" != "1" && "$has_read_index" -eq 0 && "$has_write_index" -eq 0 && -f "$index_file" ]]; then
  args+=(--read-index "$index_file")
fi

exec "$loogle_bin" "${args[@]}" "$@"
