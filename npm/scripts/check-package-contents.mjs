import { execFileSync } from "node:child_process";

const output = execFileSync("npm", ["pack", "--dry-run", "--json", "--ignore-scripts"], {
  encoding: "utf8",
});
const [{ files }] = JSON.parse(output);
const paths = new Set(files.map((file) => file.path));

const requiredPaths = [
  "package.json",
  "README.md",
  "LICENSE",
  "dist/index.js",
  "dist/index.cjs",
  "dist/fields.js",
  "dist/fields.cjs",
  "dist/ui.js",
  "dist/ui.cjs",
  "dist/components.js",
  "dist/components.cjs",
  "dist/pages.js",
  "dist/pages.cjs",
];

const missing = requiredPaths.filter((path) => !paths.has(path));
if (missing.length > 0) {
  throw new Error(`npm package is missing required files: ${missing.join(", ")}`);
}

const sourceFiles = [...paths].filter((path) => path.startsWith("src/"));
if (sourceFiles.length > 0) {
  throw new Error(`npm package should not include source files: ${sourceFiles.join(", ")}`);
}
