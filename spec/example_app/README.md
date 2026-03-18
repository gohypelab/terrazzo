# Terrazzo Example App

A Rails 8 app used for integration and system testing of the Terrazzo gem. It ships in a **base state** — a working Rails app with models, build tooling, and test specs, but no Terrazzo admin panel. The admin panel is what the Terrazzo generators create.

## Base state

The base state is tracked by a git repo inside this directory (`spec/example_app/.git`), separate from the main Terrazzo repo. It includes:

**App infrastructure (exists before Terrazzo):**
- **Models** (`app/models/`) — Customer, Order, Product, Payment, LineItem, LogEntry, Page, Series, Host, Country, ProductMetaTag, Blog::Post, Blog::Tag
- **Schema & seeds** (`db/`) — database structure and sample data
- **Gemfile** — includes `terrazzo` gem from local path (`../..`)
- **package.json** — npm deps (React, Redux, Radix UI, Superglue, Tailwind, esbuild) and build scripts
- **esbuild.config.mjs** — JS bundler config with dedupe plugin for local npm package
- **components.json** — shadcn/ui CLI config
- **jsconfig.json** — path aliases
- **Routes** — bare Rails routes (no admin namespace)

**Test infrastructure:**
- **Factories** (`spec/factories/`) — factory definitions for all models
- **System specs** (`spec/system/`) — Capybara browser tests

The base state does **not** include (these are all created by `terrazzo:install`):
- `app/dashboards/` — dashboard definitions
- `app/controllers/admin/` — admin controllers
- `app/views/admin/` — React page views, components, UI primitives, field renderers
- `app/views/layouts/admin/` — admin layout (HTML + JSON props)
- `app/javascript/admin/` — JS entry point, Redux store, slices, visit helper, page mapping
- `app/assets/stylesheets/admin.css` — Tailwind CSS theme
- Admin routes in `config/routes.rb`

## Testing the install flow

From the repo root:

```bash
cd spec/example_app
bin/rails generate terrazzo:install admin --bundler=esbuild
npm install && npm run build
bin/dev
```

Visit `http://localhost:3000/admin`.

## Resetting to base state

From the repo root:

```bash
script/reset_example_app
```

This runs `git checkout . && git clean -fd` inside the example app, restoring it to the base state, then reinstalls dependencies.

## Running tests

```bash
# Unit tests (from repo root) — work against the base state
bundle exec rspec spec/lib/

# System tests (requires the generators to have been run and assets built)
cd spec/example_app && bundle exec rspec
```
