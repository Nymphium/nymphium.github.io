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

has_diff=0

echo "| Page | Viewport | Diff pixels | Status |"
echo "|------|----------|-------------|--------|"

for page_dir in "$prod_dir"/*/; do
  [ -d "$page_dir" ] || continue
  page="$(basename "$page_dir")"
  page_diff_dir="$diff_dir/$page"
  mkdir -p "$page_diff_dir"

  for prod_img in "$page_dir"*.png; do
    [ -f "$prod_img" ] || continue
    viewport="$(basename "$prod_img" .png)"
    local_img="$local_dir/$page/$viewport.png"
    diff_img="$page_diff_dir/$viewport.png"

    if [ ! -f "$local_img" ]; then
      echo "| $page | $viewport | N/A | MISSING |"
      has_diff=1
      continue
    fi

    # magick compare returns 1 when images differ, 2 on error
    # magick compare outputs "N (ratio)" to stderr; extract just the integer
    raw=$(magick compare -metric AE "$prod_img" "$local_img" "$diff_img" 2>&1 || true)
    pixels="${raw%% *}"
    pixels="${pixels%%.*}"

    if ! [[ "$pixels" =~ ^[0-9]+$ ]]; then
      echo "| $page | $viewport | N/A | ERROR |"
      echo "Error: 'magick compare' produced non-numeric output: '$raw'" >&2
      has_diff=1
    elif [ "$pixels" -gt "$THRESHOLD" ]; then
      echo "| $page | $viewport | $pixels | FAIL |"
      has_diff=1
    else
      echo "| $page | $viewport | $pixels | PASS |"
    fi
  done
done

exit "$has_diff"
