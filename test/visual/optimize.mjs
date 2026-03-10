#!/usr/bin/env node

import { readdirSync } from "node:fs";
import { execFileSync } from "node:child_process";
import { join } from "node:path";

const dir = process.argv[2];
if (!dir) {
  console.error("Usage: node optimize.mjs <screenshot-dir>");
  process.exit(1);
}

const pngs = readdirSync(dir).filter((f) => f.endsWith(".png"));
for (const png of pngs) {
  const path = join(dir, png);
  console.log(`optipng: ${path}`);
  execFileSync("optipng", ["-o2", "-quiet", path]);
}
console.log(`Optimized ${pngs.length} images`);
