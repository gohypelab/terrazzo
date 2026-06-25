# Terrazzo

React admin package for the Terrazzo Rails gem.

Terrazzo provides default React pages, components, fields, UI primitives,
registries, hooks, and helpers used by the Rails install generator. Install it
alongside the `terrazzo` Ruby gem in a Rails app that uses Superglue.

```bash
npm install terrazzo
```

## Public Entry Points

The package exposes these supported imports:

- `terrazzo` - helpers, hooks, and registries (`cn`, `csrfToken`, `setLayout`, `registerComponent`, `registerFieldType`, etc.)
- `terrazzo/pages` - default Superglue page components
- `terrazzo/fields` - field renderer and built-in field components
- `terrazzo/components` - admin layout/table/navigation/action components
- `terrazzo/ui` - shadcn-style UI primitives used by the defaults

Do not import from `terrazzo/src`, `terrazzo/dist`, or individual internal files.
Those paths are not part of the public contract.

## App-Owned Overrides

The Rails generator creates app-level barrels that re-export package defaults:

```js
export * from "terrazzo/fields";
export * from "terrazzo/components";
export * from "terrazzo/ui";
```

Ejection appends local registrations to those barrels, so packaged pages and
ejected pages share the same override path. For example, ejected fields register
with `registerFieldType`, ejected components register with `registerComponent`,
and an ejected `Layout` calls `setLayout`.

Use the Rails ejection generators when you want supported app-owned source:

```bash
bin/rails generate terrazzo:eject pages/index
bin/rails generate terrazzo:eject fields/string
bin/rails generate terrazzo:eject components/Layout
```

App-owned/ejected files should import local components, fields, and UI primitives
through the generated app barrels such as `../fields`, `../components`, and
`../components/ui`.

Full documentation: https://gohypelab.github.io/terrazzo/
