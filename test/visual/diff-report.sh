#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 <screenshots-dir> <output-html>" >&2
  exit 1
}

[ $# -eq 2 ] || usage

screenshots_dir="$1"
output="$2"

diff_dir="$screenshots_dir/diff"
prod_dir="$screenshots_dir/production"
local_dir="$screenshots_dir/local"

tmpl_dir="$(cd "$(dirname "$0")" && pwd)"
tmpl="$tmpl_dir/diff-report.html.tmpl"

# Split template at markers and write output
while IFS= read -r line; do
  case "$line" in
    *'<!-- OPTIONS -->'*)
      for page_dir in "$diff_dir"/*/; do
        [ -d "$page_dir" ] || continue
        page="$(basename "$page_dir")"
        echo "<option value='${page}'>${page}</option>"
      done
      ;;
    *'<!-- PANELS -->'*)
      for page_dir in "$diff_dir"/*/; do
        [ -d "$page_dir" ] || continue
        page="$(basename "$page_dir")"
        for diff_img in "$page_dir"*.png; do
          [ -f "$diff_img" ] || continue
          viewport="$(basename "$diff_img" .png)"
          prod="$prod_dir/${page}/${viewport}.png"
          local="$local_dir/${page}/${viewport}.png"
          echo "<div class='panel' data-page='${page}' data-viewport='${viewport}'>"
          echo "<h2>${page} / ${viewport}</h2><div class='imgs'>"
          for pair in "Production:$prod" "Local:$local" "Diff:$diff_img"; do
            label="${pair%%:*}"; img="${pair#*:}"
            if [ -f "$img" ]; then
              name="$(basename "$img" .png)"
              thumb="${img%/*}/thumbs/${name}.jpg"
              if [ -f "$thumb" ]; then
                mime="image/jpeg"
              else
                thumb="$img"; mime="image/png"
              fi
              b64="$(base64 -w0 "$thumb")"
              echo "<figure><figcaption>${label}</figcaption><img data-src='data:${mime};base64,${b64}'></figure>"
            fi
          done
          echo "</div></div>"
        done
      done
      ;;
    *)
      echo "$line"
      ;;
  esac
done < "$tmpl" > "$output"
