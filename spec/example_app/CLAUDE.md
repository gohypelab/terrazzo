# Example App — CLAUDE.md

This is the Terrazzo example app, used for running system specs and for testing the gem's install flow.

The full admin panel — dashboards, controllers, React views, and all hand-written customizations — is **committed in the outer Terrazzo repo** and is what the system specs run against. You do **not** generate anything to run the specs.

A second, **inner** git repo (`spec/example_app/.git`) tracks a stripped **base state** with no admin panel. It exists only so `script/reset_example_app` can test the `terrazzo:install` generator from a clean slate.

## Two states

**Curated state — committed in the OUTER repo** (already present on a normal checkout):
- `app/dashboards/`, `app/controllers/admin/`, `app/views/admin/`, `app/views/layouts/admin/`
- `app/javascript/admin/`, `app/javascript/admin.js`, `app/assets/stylesheets/admin.css`
- Admin routes + customizations in `config/routes.rb`
- Hand-written customizations layered on the generated defaults: ejected pages/fields, a custom layout, bulk/row/toolbar actions, grouped navigation, dashboard hooks, and app-owned override registries

**Base state — tracked by the INNER repo** (`spec/example_app/.git`), used only for install-flow testing:
- `app/models/`, `db/` (schema, seeds, migrations)
- `package.json`, `esbuild.config.mjs`, `components.json`, `jsconfig.json`, `Gemfile`
- `spec/` — factories and system specs

> The curated admin panel is **not** reproducible from the generator alone — the customizations are hand-written. The outer repo is the source of truth for them; a clean `terrazzo:install` only produces the defaults.

## Running the system specs

The admin panel is already committed, so just build assets and run the specs:

```bash
# from the repo root
cd npm && npm run build              # build the terrazzo npm package (dist/)
cd ../spec/example_app
npm install                          # first time / after dependency changes (links terrazzo via file:../../npm)
npm run build                        # build admin assets (esbuild → admin.js bundle + Tailwind CSS)
bin/rails db:test:prepare            # first time / after schema changes
bundle exec rspec                    # system specs (requires headless Chrome; set HEADED=1 to watch)
```

After changing anything under `npm/`, rebuild **both** the npm package and the example assets — the app bundles the built `dist/`, not the source.

## Testing the install generator from scratch

Only needed to verify `terrazzo:install` itself — not to run the specs.

```bash
script/reset_example_app             # strip the admin panel back to base state (inner repo)
cd spec/example_app
bin/rails generate terrazzo:install --namespace=admin --bundler=esbuild
```

The generator scaffolds the admin application controller and layout; the JS entry point, store, slices, visit helper, and page mapping; runs the views and routes generators; and auto-discovers each model to create a dashboard + controller. It produces a **default** admin panel only.

To return to the curated, suite-passing state, restore the committed admin panel from the outer repo and rebuild:

```bash
git -C ../.. checkout HEAD -- spec/example_app/app spec/example_app/config/routes.rb
cd ../.. && cd npm && npm run build && cd ../spec/example_app && npm run build
bundle exec rspec
```

`script/reset_example_app` runs `git checkout . && git clean -fd` against the inner repo, which deletes the admin panel from disk. This is safe: every admin file is committed in the outer repo and restored by the `git checkout` above. The system specs are part of the inner base state, so they survive the reset.

## When to reset

Reset (`script/reset_example_app`) only when you are **testing the install generator** or need a clean slate to debug the install flow.

Do **not** reset when:
- Running unit specs (`bundle exec rspec spec/lib/`) — they don't use this app's admin panel
- Running the system specs — the admin panel is already committed; just build and run
- Iterating on generated/customized frontend code you want to keep

## When to change the gem source (`lib/`)

Change files in `lib/` (at the repo root) when:
- Fixing or adding field types (`lib/terrazzo/fields/`)
- Changing the dashboard DSL (`lib/terrazzo/base_dashboard.rb`)
- Changing query logic (search, filter, ordering)
- Changing what the generators produce (`lib/generators/terrazzo/`)
- Changing engine controllers or views (`app/` at repo root)

After changing gem source, run `bundle exec rspec spec/lib/` from the repo root. If you changed a generator, test the install flow (above) to verify its output.

## When to change the npm package (`npm/`)

Change files in `npm/` (at the repo root) when:
- Changing utility functions (`cn`, `truncate`, `formatDate`, etc.)
- Changing hooks (`useIsMobile`, `useAppSelector`)
- Changing the field registry API
- Changing store helpers

After changing the npm package, rebuild it (`cd npm && npm run build`) and then rebuild the example app assets (`cd spec/example_app && npm run build`).

## When to change the root CLAUDE.md

Update `/CLAUDE.md` (the repo root) when:
- Adding or removing test files or test directories
- Changing how tests should be run
- Changing the project structure or key directories
- Adding new generators or changing generator conventions
- Changing documentation rules or commit style conventions

Do NOT duplicate example-app-specific instructions there — keep those here.

## When to change THIS file

Update this `CLAUDE.md` when:
- The curated or base state contents change (files added/removed)
- The install flow changes (different generator commands or options)
- The reset/restore process changes
- New workflows are added for testing the example app

## Changing committed admin files vs base-state files

- **Admin panel / customizations** (dashboards, controllers, views, admin routes): edit and commit in the **outer** repo. These are the curated state.
- **Base-state files** (model, seed, factory, build config, specs): edit, then
  1. Commit to the **inner** repo: `cd spec/example_app && git add -A && git commit -m "description"` — this is what `script/reset_example_app` restores to
  2. Commit to the **outer** repo too — it tracks these files as well

## Key differences from a normal Rails app

- `CustomerDashboard` used by unit tests lives in `spec/support/test_dashboard.rb` (at the repo root), NOT in this app
- The `terrazzo` gem is loaded from `path: "../.."` (repo root); the `terrazzo` npm package from `file:../../npm`
- `esbuild.config.mjs` has a dedupe plugin to handle the local npm symlink, and bundles `app/javascript/admin.js`
- System specs require the assets to be built first
