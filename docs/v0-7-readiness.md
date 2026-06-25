# v0.7 Readiness

Terrazzo v0.7 is the real-app readiness milestone. The release focuses on making Terrazzo dependable in existing Rails applications, not on broadening the field catalog or redesigning the UI.

## Release Goal

Make Terrazzo safe to install, customize, test, and ship in non-trivial Rails apps:

- Fresh Vite and esbuild installs with explicit admin entrypoints.
- Reliable Tailwind CSS 4, shadcn metadata, and admin stylesheet setup.
- App-owned ejection and override registries as a supported customization contract.
- Consistent namespaced model, controller, route, and view generation.
- Stable default CRUD workflows for search, filters, sorting, pagination, CSV export, row actions, bulk actions, toolbar actions, and authorization-aware action visibility.
- Package export checks for the npm entrypoints and generated template imports.
- Example app coverage for default and customized admin flows.

## Not In Scope

v0.7 does not aim to add unrelated field types, redesign the admin shell, or introduce a complex query builder. Those should remain separate product decisions.
