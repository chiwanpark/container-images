import "./pkg-runtime-fix.mjs";
import { existsSync } from "node:fs";
import { pathToFileURL } from "node:url";

const script = process.argv[2];

if (script && /\.[cm]?js$/.test(script) && existsSync(script)) {
  process.argv.splice(1, 1);
  await import(pathToFileURL(script).href);
} else {
  await import("@getpaseo/cli/dist/index.js");
}
