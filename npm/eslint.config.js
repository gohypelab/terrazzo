import react from "eslint-plugin-react";

const readonlyGlobals = Object.fromEntries(
  [
    "clearTimeout",
    "console",
    "CustomEvent",
    "document",
    "Event",
    "FormData",
    "HTMLElement",
    "localStorage",
    "navigator",
    "Node",
    "requestAnimationFrame",
    "sessionStorage",
    "setTimeout",
    "URL",
    "window",
    "afterEach",
    "beforeEach",
    "describe",
    "expect",
    "it",
    "vi"
  ].map((name) => [name, "readonly"])
);

export default [
  {
    ignores: ["dist/**", "node_modules/**"]
  },
  {
    files: ["src/**/*.{js,jsx}"],
    languageOptions: {
      ecmaVersion: "latest",
      sourceType: "module",
      parserOptions: {
        ecmaFeatures: {
          jsx: true
        }
      },
      globals: readonlyGlobals
    },
    plugins: {
      react
    },
    rules: {
      "no-undef": "error",
      "no-unused-vars": ["error", { varsIgnorePattern: "^React$", argsIgnorePattern: "^_" }],
      "react/jsx-no-undef": "error",
      "react/jsx-uses-vars": "error"
    }
  }
];
