import { defineConfig } from "tsup"

export default defineConfig({
  entry: {
    index: "src/index.js",
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
  ],
  jsx: "automatic",
})
