# CLAUDE.md — Terrazzo

## Project overview

Terrazzo is a Ruby gem + npm package that provides a drop-in admin panel for Rails apps. It uses the Administrate dashboard DSL with a React SPA frontend powered by Superglue. UI is built with shadcn/ui + Tailwind.

## Key directories

- `lib/` — gem source (fields, base dashboard, generators)
- `lib/generators/terrazzo/` — Rails generators (install, dashboard, views, routes, field)
- `app/` — engine controllers, views, and assets
- `docs/` — VitePress documentation site (deployed to GitHub Pages)
- `spec/` — RSpec tests, including `spec/example_app/` for system specs

## Tests

### Structure

Tests are split into two suites:

**Unit tests (`spec/lib/`)** — fast, no browser required:
- `spec/lib/fields/` — field type behavior (string, number, boolean, select, belongs_to, has_many, has_one, polymorphic, deferred)
- `spec/lib/pages/` — page rendering (collection, form, show)
- `spec/lib/base_dashboard_spec.rb` — dashboard DSL
- `spec/lib/filter_spec.rb`, `search_spec.rb`, `order_spec.rb`, `default_sorting_spec.rb` — query features
- `spec/lib/grouped_attributes_spec.rb`, `resource_resolver_spec.rb` — utilities
- Helper utilities in `spec/support/model_helpers.rb`

**System tests (`spec/example_app/spec/system/`)** — full browser integration via Capybara + headless Chrome:
- 12 resource specs (customers, orders, products, payments, line_items, log_entries, pages, series, product_meta_tags, blog_posts, blog_tags)
- `navigation_spec.rb` — sidebar, search, pagination
- Factories in `spec/example_app/spec/factories/`
- Assets are auto-precompiled before the suite runs (`npm run build`)
- Set `HEADED=1` to run with a visible Chrome window

### Commands

```bash
bundle exec rspec                          # unit specs (spec/lib/ only, per Rakefile)
bundle exec rspec spec/lib/                # unit specs explicitly
cd spec/example_app && bundle exec rspec   # system specs (requires Chrome)
```

### When to run tests

**Always run the relevant tests after making changes.** Use this guide:

- **Changed a field type** (`lib/terrazzo/fields/`) → run `bundle exec rspec spec/lib/fields/`
- **Changed the dashboard DSL** (`lib/terrazzo/base_dashboard.rb`) → run `bundle exec rspec spec/lib/`
- **Changed query logic** (filtering, search, ordering) → run the corresponding spec in `spec/lib/`
- **Changed page rendering** (`lib/terrazzo/pages/`) → run `bundle exec rspec spec/lib/pages/`
- **Changed a generator** (`lib/generators/`) → run the full unit suite (`bundle exec rspec`) and manually verify generated output if needed
- **Changed controllers, views, or frontend components** → run system specs (`cd spec/example_app && bundle exec rspec`)
- **Before committing any non-trivial change** → run the full unit suite at minimum (`bundle exec rspec`)
- **If unit tests pass but you're unsure about integration** → also run system specs

If a test fails, fix the issue before proceeding. Do not commit code with failing tests.

## Documentation rules

Documentation lives in `docs/` (VitePress) and `README.md`. Keep them in sync with code changes:

- **When to update `README.md`**: Changes to installation steps, quick-start flow, supported Ruby/Rails/Node versions, or the project description.
- **When to update `docs/guide/getting-started.md`**: Changes to the install generator, setup steps, or prerequisites.
- **When to update `docs/reference/generators.md`**: Adding/removing/changing generator options, generated files, or generator behavior.
- **When to update `docs/reference/field-types.md`**: Adding a new field type, changing field options, or modifying field behavior.
- **When to update `docs/reference/dashboards.md`**: Changes to the dashboard DSL (ATTRIBUTE_TYPES, COLLECTION_ATTRIBUTES, etc.), adding/changing instance methods or overridable hooks on `BaseDashboard`.
- **When to update `docs/guide/fields.md`**: Changes to how fields are configured or used in dashboards.
- **When to update `docs/guide/dashboards.md`**: Changes to dashboard generation, customization, conventions, or adding new overridable dashboard methods.
- **When to update `docs/guide/controllers.md`**: Changes to controller generation or admin controller behavior.
- **When to update `docs/guide/views.md`**: Changes to view components or the views generator.

**General rule**: If you change a generator, field type, DSL behavior, or install flow, update the corresponding doc(s) and README in the same changeset. Do not leave docs out of date.

## Version management

The version string lives in two places that must stay in sync:
- `lib/terrazzo/version.rb` — gem version (source of truth)
- `npm/package.json` — npm package version

`docs/.vitepress/config.mjs` reads the version from `npm/package.json` automatically.

## Code conventions

- Generators live under `lib/generators/terrazzo/<name>/` with a `<name>_generator.rb` and a `templates/` directory.
- Dashboard classes inherit from `Terrazzo::BaseDashboard`.
- Field classes live in `Terrazzo::Field` namespace.
- Tests use RSpec. System specs use Capybara with headless Chrome.
- The example app in `spec/example_app/` is a full Rails app used for integration/system testing.

## Commit style

Follow conventional-ish commits: lead with what changed (e.g., "Add --bundler option to install generator", "Fix polymorphic field rendering"). Keep the first line under 72 chars.
