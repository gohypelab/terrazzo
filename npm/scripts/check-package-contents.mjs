import { execFileSync } from "node:child_process";
import { readFileSync, writeFileSync } from "node:fs";

const packageJsonPath = new URL("../package.json", import.meta.url);
const packageJsonRaw = readFileSync(packageJsonPath, "utf8");
const packageJson = JSON.parse(packageJsonRaw);

const expectedMetadata = {
  name: "terrazzo",
  license: "MIT",
  homepage: "https://gohypelab.github.io/terrazzo/",
  repository: {
    type: "git",
    url: "git+https://github.com/gohypelab/terrazzo.git",
    directory: "npm",
  },
  bugs: {
    url: "https://github.com/gohypelab/terrazzo/issues",
  },
  engines: {
    node: ">=18",
  },
};

for (const [key, expected] of Object.entries(expectedMetadata)) {
  const actual = packageJson[key];
  if (JSON.stringify(actual) !== JSON.stringify(expected)) {
    throw new Error(
      `package.json ${key} metadata is ${JSON.stringify(actual)}, expected ${JSON.stringify(expected)}`
    );
  }
}

for (const keyword of ["rails", "react", "superglue", "administrate"]) {
  if (!packageJson.keywords?.includes(keyword)) {
    throw new Error(`package.json keywords is missing ${keyword}`);
  }
}

// npm 10 runs "prepare" during `pack` even with --ignore-scripts (fixed in npm 11),
// which pollutes the captured stdout with tsup's banner ahead of the JSON. dist/ is
// already built by this point, so drop "prepare" from the on-disk package.json before
// packing and restore it afterward.
const packageJsonWithoutPrepare = { ...packageJson, scripts: { ...packageJson.scripts } };
delete packageJsonWithoutPrepare.scripts.prepare;
writeFileSync(packageJsonPath, JSON.stringify(packageJsonWithoutPrepare, null, 2) + "\n");

let output;
try {
  output = execFileSync("npm", ["pack", "--dry-run", "--json", "--ignore-scripts"], {
    encoding: "utf8",
  });
} finally {
  writeFileSync(packageJsonPath, packageJsonRaw);
}
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
