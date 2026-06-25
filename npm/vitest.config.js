import { fileURLToPath } from "node:url"
import { defineConfig } from "vitest/config"

const src = (path) => fileURLToPath(new URL(path, import.meta.url))

export default defineConfig({
  resolve: {
    alias: [
      { find: /^terrazzo$/, replacement: src("./src/index.js") },
      { find: /^terrazzo\/fields$/, replacement: src("./src/fields/index.js") },
      { find: /^terrazzo\/ui$/, replacement: src("./src/ui/index.js") },
      { find: /^terrazzo\/components$/, replacement: src("./src/components/index.js") },
      { find: /^terrazzo\/pages$/, replacement: src("./src/pages/index.js") },
    ],
  },
  test: {
    environment: "jsdom",
    globals: true,
    setupFiles: ["./src/test-setup.js"],
  },
})
