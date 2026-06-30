# Terrazzo Example App

A Rails 8 app used for integration and system testing of the Terrazzo gem.

The admin panel here is a **build artifact**, not committed source. It's produced by
`script/build_example_admin` — the "customize recipe": run the real Terrazzo generators
(`terrazzo:install` + ejects + page-view overrides) to scaffold the *current* defaults, then
drop the authored customizations from `overlay/` on top. The system specs run against that
freshly-built panel, so they always exercise the current generator output rather than
committed scaffolding that can silently drift from the gem.

## What's committed vs. generated

**Committed** (present on a normal checkout):
- Models (`app/models/`), schema, seeds, factories, and the system specs
- Build tooling (`package.json`, `esbuild.config.mjs`, `components.json`, `jsconfig.json`) and `Gemfile`
- `config/routes.rb` — you own your routes (the Administrate model)
- `overlay/` — the authored customizations the specs exercise
- `script/build_example_admin` — the recipe

**Generated** (gitignored — built by the recipe):
- `app/dashboards/`, `app/controllers/admin/`, `app/views/admin/`, `app/views/layouts/admin/`
- `app/javascript/admin/`, `app/javascript/admin.js`, `app/assets/stylesheets/admin.css`

## Running the system specs

```bash
# from the repo root — one-time / after dependency or gem changes
cd npm && npm run build              # build the terrazzo npm package (dist/)
cd ../spec/example_app
npm install                          # link terrazzo (file:../../npm) + install deps
bundle install

# build the admin panel, then run the specs
script/build_example_admin           # generate the admin from the generators + overlay/
bin/rails db:test:prepare            # first time / after schema changes
bundle exec rspec                    # system specs (headless Chrome; HEADED=1 to watch)
```

Run `script/build_example_admin` before `bundle exec rspec` — it generates the admin and
compiles assets. (If you forget, the specs stop with a reminder.) Re-run it after you change
the gem (`lib/`, generators) or anything in `overlay/`. CI always rebuilds from scratch.

## The customizations (`overlay/`)

`overlay/` holds only the irreducible, hand-authored customizations — the parts a generator
can't produce. Everything else (default pages, barrels, JS entry/store, every default
dashboard/controller, and roughly half the resources) is generated, so the specs test the
generators against the real schema. Highlights:

- **Fields** — boolean/email icons, string test hooks
- **Components** — custom `Layout` (`setLayout`) and `SearchBar`
- **Pages** — customers card-grid index, orders show with a `totalPrice` prop
- **Dashboards** — collection/bulk actions, filters, `with_options`, display hooks
- **Controller** — orders `bulk_ship` / `invoice`

## Running unit specs

```bash
# from the repo root — these don't need the example app's admin panel
bundle exec rspec spec/lib/
```
