#!/usr/bin/env node

import { mkdirSync } from "node:fs";
import { firefox } from "playwright-core";

const VIEWPORTS = [
  { label: "tablet", width: 1024, height: 768 },
  { label: "desktop", width: 1280, height: 1024 },
];

const PAGES = [
  { label: "homepage", path: "/" },
  { label: "about", path: "/about/README.html" },
  {
    label: "blog",
    path: "/2018/12/09/asymmetric-coroutines%E3%81%AB%E3%82%88%E3%82%8Boneshot-algebraic-effects%E3%81%AE%E5%AE%9F%E8%A3%85.html",
  },
  { label: "slide", path: "/pdf/gocon2024" },
];

async function main() {
  const [origin, outDir] = process.argv.slice(2);
  if (!origin || !outDir) {
    console.error("Usage: node screenshots.mjs <origin-url> <output-dir>");
    process.exit(1);
  }

  mkdirSync(outDir, { recursive: true });

  const browser = await firefox.launch({ headless: true });

  try {
    for (const viewport of VIEWPORTS) {
      for (const pg of PAGES) {
        // Fresh context per page so no :visited history accumulates
        const context = await browser.newContext({
          viewport: { width: viewport.width, height: viewport.height },
        });
        const page = await context.newPage();

        const url = new URL(pg.path, origin).href;
        console.log(`[${viewport.label}] ${pg.label}: ${url}`);

        await page.goto(url, { waitUntil: "networkidle", timeout: 30000 });
        // Freeze CSS animations so timing-dependent styles (e.g. .rainbow hue-rotate) are deterministic
        await page.addStyleTag({
          content: "*, *::before, *::after { animation: none !important; transition: none !important; }",
        });
        await page.waitForTimeout(3000);

        if (pg.label === "slide") {
          await page.waitForSelector("canvas", { timeout: 30000 });
          await page.waitForTimeout(2000);
        }

        const filename = `${pg.label}_${viewport.label}.png`;
        await page.screenshot({
          path: `${outDir}/${filename}`,
          fullPage: true,
        });
        console.log(`  -> ${outDir}/${filename}`);

        await context.close();
      }
    }
  } finally {
    await browser.close();
  }
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
