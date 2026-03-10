#!/usr/bin/env node

import { existsSync, mkdirSync, readdirSync } from "node:fs";
import { execFileSync } from "node:child_process";
import { join } from "node:path";

const dir = process.argv[2];
if (!dir) {
  console.error("Usage: node optimize.mjs <screenshot-dir>");
  process.exit(1);
}

if (!existsSync(dir)) {
  console.warn(`Directory not found: ${dir}, skipping`);
  process.exit(0);
}

const pngs = readdirSync(dir).filter((f) => f.endsWith(".png"));
const thumbDir = join(dir, "thumbs");
mkdirSync(thumbDir, { recursive: true });

for (const png of pngs) {
  const path = join(dir, png);
  console.log(`optipng: ${path}`);
  execFileSync("optipng", ["-o1", "-quiet", "-strip", "all", path]);

  const dst = join(thumbDir, png);
  console.log(`thumbnail: ${dst}`);
  execFileSync("magick", [
    path,
    "-resize",
    "360x",
    "-strip",
    "-define",
    "png:compression-level=9",
    dst,
  ]);
}

console.log(`Optimized ${pngs.length} images`);
