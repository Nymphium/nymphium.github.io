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

cat > "$output" <<'HEADER'
<!DOCTYPE html>
<html><head><meta charset="utf-8"><title>Visual Regression Diff</title>
<style>
body{font-family:system-ui;max-width:1400px;margin:0 auto;padding:20px;background:#f6f8fa}
h1{border-bottom:2px solid #d0d7de;padding-bottom:8px}
.controls{display:flex;align-items:center;gap:12px;margin-bottom:16px}
select{padding:6px 12px;border:1px solid #d0d7de;border-radius:6px;font-size:14px;background:#fff}
nav{display:flex;gap:8px;flex-wrap:wrap}
nav a{padding:6px 12px;border:1px solid #d0d7de;border-radius:6px;text-decoration:none;color:#0969da;background:#fff;cursor:pointer}
nav a.active{background:#0969da;color:#fff}
.panel{display:none}
.panel.active{display:block}
.panel h2{margin-top:0}
.imgs{display:flex;gap:8px;overflow-x:auto}
.imgs figure{margin:0;flex:1;min-width:0}
.imgs figcaption{font-weight:600;text-align:center;padding:4px 0}
.imgs img{max-width:100%;border:1px solid #d0d7de;display:block}
</style></head><body>
<h1>Visual Regression Diff</h1>
<div class="controls">
<select id="ps" onchange="selectPage(this.value)">
HEADER

# Populate page dropdown
for page_dir in "$diff_dir"/*/; do
  [ -d "$page_dir" ] || continue
  page="$(basename "$page_dir")"
  echo "<option value='${page}'>${page}</option>" >> "$output"
done
echo "</select><nav id='vt'></nav></div>" >> "$output"

# Generate panels
for page_dir in "$diff_dir"/*/; do
  [ -d "$page_dir" ] || continue
  page="$(basename "$page_dir")"
  for diff_img in "$page_dir"*.png; do
    [ -f "$diff_img" ] || continue
    viewport="$(basename "$diff_img" .png)"
    prod="$prod_dir/${page}/${viewport}.png"
    local="$local_dir/${page}/${viewport}.png"
    echo "<div class='panel' data-page='${page}' data-viewport='${viewport}'><h2>${page} / ${viewport}</h2><div class='imgs'>" >> "$output"
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
        echo "<figure><figcaption>${label}</figcaption><img data-src='data:${mime};base64,${b64}'></figure>" >> "$output"
      fi
    done
    echo "</div></div>" >> "$output"
  done
done

cat >> "$output" <<'FOOTER'
<script>
const ps=document.getElementById('ps'),vt=document.getElementById('vt');
const panels=[...document.querySelectorAll('.panel')];
function selectPage(page){
  ps.value=page;
  vt.innerHTML='';
  const vps=[...new Set(panels.filter(p=>p.dataset.page===page).map(p=>p.dataset.viewport))];
  vps.forEach(vp=>{
    const a=document.createElement('a');a.textContent=vp;a.href='#';
    a.onclick=e=>{e.preventDefault();selectViewport(page,vp);};
    vt.appendChild(a);
  });
  if(vps.length)selectViewport(page,vps[0]);
}
function selectViewport(page,viewport){
  panels.forEach(p=>p.classList.remove('active'));
  vt.querySelectorAll('a').forEach(a=>a.classList.toggle('active',a.textContent===viewport));
  const el=panels.find(p=>p.dataset.page===page&&p.dataset.viewport===viewport);
  if(el){
    el.classList.add('active');
    el.querySelectorAll('img[data-src]').forEach(i=>{i.src=i.dataset.src;i.removeAttribute('data-src');});
  }
  history.replaceState(null,'','#'+page+'_'+viewport);
}
const h=location.hash.slice(1);
if(h){const[p,v]=h.split('_');if(p){selectPage(p);if(v)selectViewport(p,v);}}
else if(ps.options.length)selectPage(ps.value);
window.addEventListener('hashchange',()=>{const[p,v]=location.hash.slice(1).split('_');if(p)selectPage(p);if(v)selectViewport(p,v);});
</script></body></html>
FOOTER
