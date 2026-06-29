# Terrazzo Example App

A Rails 8 app used for integration and system testing of the Terrazzo gem. The repo includes a **fully built, customized admin panel** that the system specs run against — you don't generate anything to run them.

A separate, **inner** git repo (`spec/example_app/.git`) tracks a stripped **base state** with no admin panel. It exists only so `script/reset_example_app` can test the `terrazzo:install` generator from a clean slate.

## Running the system specs

```bash
# from the repo root
cd npm && npm run build              # build the terrazzo npm package
cd ../spec/example_app
npm install                          # first time / after dependency changes
npm run build                        # build admin assets (esbuild + Tailwind)
bin/rails db:test:prepare            # first time / after schema changes
bundle exec rspec                    # system specs (requires headless Chrome)
```

## What's committed vs the base state

**Committed admin panel** (already present; what the specs use):
- `app/dashboards/`, `app/controllers/admin/`, `app/views/admin/`, `app/views/layouts/admin/`
- `app/javascript/admin/`, `app/javascript/admin.js`, `app/assets/stylesheets/admin.css`
- Admin routes + customizations in `config/routes.rb`

**Base state** (inner repo; the app *without* the admin panel):
- Models (`app/models/`), schema & seeds (`db/`)
- Build tooling (`package.json`, `esbuild.config.mjs`, `components.json`, `jsconfig.json`)
- `Gemfile` (loads `terrazzo` from `../..`) and `spec/` (factories + system specs)

## Testing the install generator

```bash
script/reset_example_app             # strip back to base state
cd spec/example_app
bin/rails generate terrazzo:install --namespace=admin --bundler=esbuild
npm install && npm run build
bin/dev                              # visit http://localhost:3000/admin
```

This produces a **default** admin panel. The hand-written customizations the system specs exercise are not reproduced by the generator. To return to the curated, suite-passing state, restore from the outer repo:

```bash
git -C ../.. checkout HEAD -- spec/example_app/app spec/example_app/config/routes.rb
```

## Running unit tests

```bash
# from the repo root — these work without the example app's admin panel
bundle exec rspec spec/lib/
```
