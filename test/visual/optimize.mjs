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

let total = 0;

for (const entry of readdirSync(dir, { withFileTypes: true })) {
  if (!entry.isDirectory() || entry.name === "thumbs") continue;
  const subdir = join(dir, entry.name);

  const pngs = readdirSync(subdir).filter((f) => f.endsWith(".png"));
  const thumbDir = join(subdir, "thumbs");
  mkdirSync(thumbDir, { recursive: true });

  for (const png of pngs) {
    const path = join(subdir, png);
    console.log(`optipng: ${path}`);
    execFileSync("optipng", ["-o1", "-quiet", "-strip", "all", path]);

    const dst = join(thumbDir, png.replace(/\.png$/, ".jpg"));
    console.log(`thumbnail: ${dst}`);
    execFileSync("magick", [
      path,
      "-resize",
      "300x",
      "-strip",
      "-quality",
      "50",
      dst,
    ]);
  }

  total += pngs.length;
}

console.log(`Optimized ${total} images`);
