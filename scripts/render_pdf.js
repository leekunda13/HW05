#!/usr/bin/env node

const path = require("path");
const { pathToFileURL } = require("url");
const { chromium } = require("/Users/kunda/Documents/hw/hw04/node_modules/playwright");

async function main() {
  if (process.argv.length !== 4) {
    throw new Error("Usage: render_pdf.js <input.html> <output.pdf>");
  }

  const input = path.resolve(process.argv[2]);
  const output = path.resolve(process.argv[3]);
  const browser = await chromium.launch({
    executablePath: "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
    headless: true,
  });
  try {
    const page = await browser.newPage();
    await page.goto(pathToFileURL(input).href, { waitUntil: "networkidle" });
    await page.emulateMedia({ media: "print" });
    await page.pdf({
      path: output,
      format: "A4",
      printBackground: true,
      preferCSSPageSize: true,
      displayHeaderFooter: true,
      headerTemplate: "<div></div>",
      footerTemplate: `<div style="box-sizing:border-box;color:#64748b;display:flex;font-family:Arial,sans-serif;font-size:8px;justify-content:space-between;padding:0 15mm;width:100%"><span>23127035 - HW05 Task 1</span><span><span class="pageNumber"></span> / <span class="totalPages"></span></span></div>`,
    });
  } finally {
    await browser.close();
  }
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
