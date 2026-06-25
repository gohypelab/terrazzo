# Terrazzo

React admin package for the Terrazzo Rails gem.

Terrazzo provides default React pages, components, fields, UI primitives,
registries, hooks, and helpers used by the Rails install generator. Install it
alongside the `terrazzo` Ruby gem in a Rails app that uses Superglue.

```bash
npm install terrazzo
```

The Rails generator creates app-level barrels that re-export these package
defaults:

```js
export * from "terrazzo/fields";
export * from "terrazzo/components";
export * from "terrazzo/ui";
```

Use the Rails ejection generators when you want app-owned source:

```bash
bin/rails generate terrazzo:eject pages/index
bin/rails generate terrazzo:eject fields/string
bin/rails generate terrazzo:eject components/Layout
```

Full documentation: https://gohypelab.github.io/terrazzo/
