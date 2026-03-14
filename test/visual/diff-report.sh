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

html_escape() {
  local s="$1"
  s="${s//&/&amp;}"
  s="${s//</&lt;}"
  s="${s//>/&gt;}"
  s="${s//\"/&quot;}"
  s="${s//\'/&#39;}"
  echo "$s"
}

# Split template at markers and write output
while IFS= read -r line; do
  case "$line" in
    *'<!-- OPTIONS -->'*)
      for page_dir in "$diff_dir"/*/; do
        [ -d "$page_dir" ] || continue
        page="$(html_escape "$(basename "$page_dir")")"
        echo "<option value='${page}'>${page}</option>"
      done
      ;;
    *'<!-- PANELS -->'*)
      for page_dir in "$diff_dir"/*/; do
        [ -d "$page_dir" ] || continue
        raw_page="$(basename "$page_dir")"
        page="$(html_escape "$raw_page")"
        for diff_img in "$page_dir"*.png; do
          [ -f "$diff_img" ] || continue
          raw_viewport="$(basename "$diff_img" .png)"
          viewport="$(html_escape "$raw_viewport")"
          prod="$prod_dir/${raw_page}/${raw_viewport}.png"
          local="$local_dir/${raw_page}/${raw_viewport}.png"
          echo "<div class='panel' data-page='${page}' data-viewport='${viewport}'>"
          echo "<h2>${page} / ${viewport}</h2><div class='imgs'>"
          for pair in "Production:$prod" "Local:$local" "Diff:$diff_img"; do
            label="$(html_escape "${pair%%:*}")"; img="${pair#*:}"
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
