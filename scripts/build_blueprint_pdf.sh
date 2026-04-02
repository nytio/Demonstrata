#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
blueprint_src="$repo_root/blueprint/src"
build_root="$repo_root/blueprint/build"
library_dir="$repo_root/blueprint/library/pdf"
timestamp="$(date '+%Y%m%d_%H%M%S')"
source_stem="print"
build_dir="$build_root/${timestamp}_${source_stem}"
archive_pdf="$library_dir/${timestamp}_${source_stem}.pdf"

if [[ ! -f "$blueprint_src/print.tex" ]]; then
  echo "Blueprint source not found: $blueprint_src/print.tex" >&2
  exit 1
fi

mkdir -p "$build_dir" "$library_dir"

cd "$blueprint_src"

latexmk \
  -xelatex \
  -interaction=nonstopmode \
  -halt-on-error \
  -file-line-error \
  -output-directory="$build_dir" \
  print.tex

cp "$build_dir/print.pdf" "$archive_pdf"

echo "Build directory: $build_dir"
echo "Archived PDF: $archive_pdf"
