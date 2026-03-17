import * as esbuild from "esbuild"
import path from "path"
import { fileURLToPath } from "url"

const __dirname = path.dirname(fileURLToPath(import.meta.url))
const appNodeModules = path.resolve(__dirname, "node_modules")
const npmPkgPath = path.resolve(__dirname, "../../npm")

const watch = process.argv.includes("--watch")

// When terrazzo is symlinked via file:../../npm, esbuild follows the
// symlink and resolves peer deps from npm/node_modules/ instead of the app's.
// This plugin intercepts those resolutions and redirects them to the app's
// node_modules to ensure a single copy of React, Redux, and Superglue.
const dedupePlugin = {
  name: "dedupe-peer-deps",
  setup(build) {
    const peers = [
      "react",
      "react-dom",
      "react-redux",
      "@reduxjs/toolkit",
      "@thoughtbot/superglue",
    ]

    for (const pkg of peers) {
      const escaped = pkg.replace(/[/.]/g, "\\$&")
      const filter = new RegExp(`^${escaped}(\\/.*)?$`)

      build.onResolve({ filter }, (args) => {
        // Skip if already redirected (prevent infinite loop)
        if (args.pluginData?.deduped) return

        // Only redirect imports originating from the symlinked npm package
        if (!args.resolveDir.startsWith(npmPkgPath)) return

        // Re-resolve from the app's node_modules
        return build.resolve(args.path, {
          kind: args.kind,
          resolveDir: appNodeModules,
          pluginData: { deduped: true },
        })
      })
    }
  },
}

const ctx = await esbuild.context({
  entryPoints: { admin: "app/javascript/admin/application.jsx" },
  bundle: true,
  sourcemap: true,
  format: "esm",
  outdir: "app/assets/builds",
  loader: { ".js": "jsx", ".jsx": "jsx" },
  external: ["@rails/actioncable"],
  plugins: [dedupePlugin],
})

if (watch) {
  await ctx.watch()
  console.log("Watching for changes...")
} else {
  await ctx.rebuild()
  await ctx.dispose()
}
