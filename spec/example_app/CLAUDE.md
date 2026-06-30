# Example App — CLAUDE.md

This is the Terrazzo example app, used for running system specs and for testing the gem's
install + customize flow.

The admin panel is a **build artifact**, not committed source. It's produced by
`script/build_example_admin` (the "customize recipe"):

1. `terrazzo:install` + the eject and page-view generators scaffold the **current** default admin.
2. The authored customizations in `overlay/` are copied on top.

The system specs run against that freshly-built panel, so they always exercise the current
generator output — not committed scaffolding that can drift from the gem. There is no inner git
repo; this is a single repository.

## What's committed vs. generated

**Committed:**
- `app/models/`, `db/` (schema, seeds), factories, and `spec/` (system specs + support)
- Build tooling (`package.json`, `esbuild.config.mjs`, `components.json`, `jsconfig.json`), `Gemfile`
- `config/routes.rb` — you own your routes (the Administrate model; `terrazzo:routes` only seeds once)
- `overlay/` — the authored customizations
- `script/build_example_admin` — the recipe

**Generated** (gitignored — rebuilt by the recipe):
- `app/dashboards/`, `app/controllers/admin/`, `app/views/admin/`, `app/views/layouts/admin/`
- `app/javascript/admin/`, `app/javascript/admin.js`, `app/assets/stylesheets/admin.css`

## Running the system specs

```bash
# from the repo root
cd npm && npm run build              # build the terrazzo npm package (dist/)
cd ../spec/example_app
npm install                          # link terrazzo (file:../../npm) + install deps
bundle install
script/build_example_admin           # generate the admin from the generators + overlay/
bin/rails db:test:prepare            # first time / after schema changes
bundle exec rspec                    # system specs (headless Chrome; HEADED=1 to watch)
```

`script/build_example_admin` generates the admin and compiles assets; run it before
`bundle exec rspec`. The specs stop with a reminder if the admin isn't built — it must exist
before Rails boots so the admin controllers/dashboards autoload (`before(:suite)` in
`spec/support/precompile_assets.rb`). After changing anything under `npm/`, rebuild the npm
package (`cd npm && npm run build`) — the app bundles the built `dist/`, not the source.

## The recipe (`script/build_example_admin` + `overlay/`)

The recipe runs `terrazzo:install` + the ejects (`fields/boolean|email|string`,
`components/Layout|SearchBar`) + page overrides (`views:index Customer`, `views:show Order`),
then copies `overlay/` over the result.

- **Generated** (no overlay): default pages (thin re-exports), barrels, JS entry/store/mappings,
  every default dashboard/controller, ~half the resources, `admin.css`. These test the generators
  against the real schema.
- **Overlaid** (`overlay/`): the field/component/page/dashboard/controller customizations.
- **Owned/committed**: `config/routes.rb`.

Each overlaid customization is asserted by a system spec (e.g. the customers card-grid spec
asserts the default `<table>` is *absent*), so a customization that fails to take effect — or a
generator change that breaks it — fails the suite. CI rebuilds the admin from scratch and runs the
full suite on every PR.

## Changing things

- **A customization**: edit the file under `overlay/`, then re-run `script/build_example_admin`.
- **Add an ejected customization**: add the `terrazzo:eject` / `terrazzo:views:*` call to
  `script/build_example_admin`, and the authored file to `overlay/`.
- **The gem source (`lib/`)** — field types, dashboard DSL, query logic, generators, engine
  controllers/views. Run `bundle exec rspec spec/lib/` (repo root); generator output is covered by
  `spec/lib/generators/`. Then rebuild the example admin to integration-test it.
- **The npm package (`npm/`)** — utils, hooks, registry API, store. Rebuild the package, then the
  example assets.

## When to change THIS file

Update this `CLAUDE.md` when the committed/generated split changes, the recipe changes (different
generator calls or overlay files), the build/spec flow changes, or new example-app workflows are
added.

## Key differences from a normal Rails app

- `CustomerDashboard` used by unit tests lives in `spec/support/test_dashboard.rb` (repo root), NOT here
- The `terrazzo` gem is loaded from `path: "../.."`; the npm package from `file:../../npm`
- `esbuild.config.mjs` has a dedupe plugin for the local npm symlink, and bundles `app/javascript/admin.js`
- The admin panel must be built (`script/build_example_admin`) before the system specs run
