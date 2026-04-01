import { defineConfig } from "tsup"

export default defineConfig({
  entry: {
    index: "src/index.js",
    fields: "src/fields/index.js",
    ui: "src/ui/index.js",
    components: "src/components/index.js",
    pages: "src/pages/index.js",
  },
  format: ["esm", "cjs"],
  dts: false,
  sourcemap: true,
  clean: true,
  external: [
    "react",
    "react-dom",
    "react-redux",
    "@reduxjs/toolkit",
    /^@radix-ui\//,
    "@thoughtbot/superglue",
    "class-variance-authority",
    "lucide-react",
    "terrazzo",
    /^terrazzo\//,
  ],
  jsx: "automatic",
})
