#!/usr/bin/env node

import { mkdirSync, readdirSync } from "node:fs";
import { execFileSync } from "node:child_process";
import { join } from "node:path";

const dir = process.argv[2];
if (!dir) {
  console.error("Usage: node optimize.mjs <screenshot-dir>");
  process.exit(1);
}

const pngs = readdirSync(dir).filter((f) => f.endsWith(".png"));

// Lossless compression
for (const png of pngs) {
  const path = join(dir, png);
  console.log(`optipng: ${path}`);
  execFileSync("optipng", ["-o1", "-quiet", "-strip", "all", path]);
}

// Generate thumbnails for the diff viewer HTML
const thumbDir = join(dir, "thumbs");
mkdirSync(thumbDir, { recursive: true });
for (const png of pngs) {
  const src = join(dir, png);
  const dst = join(thumbDir, png);
  console.log(`thumbnail: ${dst}`);
  execFileSync("magick", [src, "-resize", "360x", "-quality", "95", dst]);
}

console.log(`Optimized ${pngs.length} images`);
