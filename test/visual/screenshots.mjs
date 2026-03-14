#!/usr/bin/env node

import { mkdirSync } from "node:fs";
import { firefox } from "playwright-core";

const VIEWPORTS = [
  { label: "mobile", width: 375, height: 812 },
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

  const browser = await firefox.launch({
    headless: true,
    firefoxUserPrefs: {
      // Disable :visited link styling so local vs production URLs
      // don't produce diffs from different visited-link state
      "layout.css.visited_links_enabled": false,
    },
  });

  try {
    for (const viewport of VIEWPORTS) {
      const context = await browser.newContext({
        viewport: { width: viewport.width, height: viewport.height },
      });
      const page = await context.newPage();

      for (const pg of PAGES) {
        const pageDir = `${outDir}/${pg.label}`;
        mkdirSync(pageDir, { recursive: true });

        const url = new URL(pg.path, origin).href;
        console.log(`[${viewport.label}] ${pg.label}: ${url}`);

        // Use "load" instead of "networkidle" — third-party scripts
        // (Twitter/Hatena/utteranc.es) can keep background requests going
        // and prevent network from ever becoming idle
        await page.goto(url, { waitUntil: "load", timeout: 30000 });

        // Cancel all running animations and prevent new ones via CSS.
        // This must happen after goto so the DOM is fully available.
        await page.evaluate(() => {
          document.getAnimations().forEach((a) => a.cancel());
        });
        await page.addStyleTag({
          content:
            "*, *::before, *::after { animation: none !important; transition: none !important; }",
        });

        if (pg.label === "blog") {
          // GithubRepoWidget.init is deferred with setTimeout(..., 3000),
          // wait for it to actually finish rendering. Fall back to a delay
          // if the GitHub API is rate-limited/unreachable.
          await page
            .waitForSelector('.github-widget[github-widget-rendered="1"]', {
              timeout: 10000,
            })
            .catch((err) => {
              if (err.name === "TimeoutError" || err.message?.includes("Timeout")) {
                console.warn("  GitHub widget timed out; falling back to delay");
                return page.waitForTimeout(5000);
              }
              throw err;
            });
        } else if (pg.label === "slide") {
          // Wait for pdf.js to create and paint the canvas
          await page.waitForSelector("canvas", { timeout: 30000 });
          await page.waitForFunction(
            () => {
              const c = document.querySelector("canvas");
              if (!c) return false;
              const r = c.getBoundingClientRect();
              return c.width > 0 && c.height > 0 && r.width > 0 && r.height > 0;
            },
            { timeout: 30000 },
          );
        }

        const filename = `${viewport.label}.png`;
        await page.screenshot({
          path: `${pageDir}/${filename}`,
          fullPage: true,
        });
        console.log(`  -> ${pageDir}/${filename}`);
      }

      await context.close();
    }
  } finally {
    await browser.close();
  }
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
