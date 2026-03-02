#!/usr/bin/env bash
set -euo pipefail

THRESHOLD="${VISUAL_DIFF_THRESHOLD:-500}"

usage() {
  echo "Usage: $0 <production-dir> <local-dir> <diff-dir>" >&2
  exit 1
}

[ $# -eq 3 ] || usage

prod_dir="$1"
local_dir="$2"
diff_dir="$3"

mkdir -p "$diff_dir"

has_diff=0

echo "| Page | Diff pixels | Status |"
echo "|------|-------------|--------|"

for prod_img in "$prod_dir"/*.png; do
  name="$(basename "$prod_img")"
  local_img="$local_dir/$name"
  diff_img="$diff_dir/$name"

  if [ ! -f "$local_img" ]; then
    echo "| $name | N/A | MISSING |"
    has_diff=1
    continue
  fi

  # magick compare returns 1 when images differ, 2 on error
  pixels=$(magick compare -metric AE "$prod_img" "$local_img" "$diff_img" 2>&1 || true)
  pixels="${pixels%%.*}" # truncate decimal if any

  if [ "$pixels" -gt "$THRESHOLD" ] 2>/dev/null; then
    echo "| $name | $pixels | FAIL |"
    has_diff=1
  else
    echo "| $name | $pixels | PASS |"
  fi
done

exit "$has_diff"
