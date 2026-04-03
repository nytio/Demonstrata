#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$repo_root"

clean_dir_contents() {
  local target="$1"
  if [[ -d "$target" ]]; then
    find "$target" -mindepth 1 -exec rm -rf -- {} +
  fi
}

remove_python_caches() {
  local target="$1"
  if [[ ! -d "$target" ]]; then
    return
  fi

  find "$target" -type d -name __pycache__ -prune -exec rm -rf -- {} +
  find "$target" -type f \( -name '*.pyc' -o -name '*.pyo' \) -delete
}

# Remove disposable blueprint build artifacts while preserving archived PDFs
# and every source file outside blueprint/build.
clean_dir_contents "blueprint/build"

if [[ -d ".pytest_cache" ]]; then
  rm -rf -- ".pytest_cache"
fi

for dir in scripts tests tools; do
  remove_python_caches "$dir"
done

echo "Removed disposable build artifacts from blueprint/build and Python caches."
