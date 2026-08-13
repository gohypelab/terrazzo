# Terrazzo

A drop-in admin panel for Rails apps. Uses the [Administrate](https://github.com/thoughtbot/administrate) dashboard DSL with a React SPA frontend powered by [Superglue](https://github.com/thoughtbot/superglue).

[![CI](https://github.com/gohypelab/terrazzo/actions/workflows/ci.yml/badge.svg)](https://github.com/gohypelab/terrazzo/actions/workflows/ci.yml)
[![Release](https://github.com/gohypelab/terrazzo/actions/workflows/release.yml/badge.svg)](https://github.com/gohypelab/terrazzo/actions/workflows/release.yml)

- **Familiar DSL** — same `ATTRIBUTE_TYPES`, `COLLECTION_ATTRIBUTES`, `FORM_ATTRIBUTES` you already know
- **React SPA** — search, sort, and paginate without full page reloads, no separate API needed
- **shadcn/ui + Tailwind** — polished defaults with supported ejection when you want app-owned source
- **19 field types** — string, text, number, money, boolean, date/time, email, URL, password, select, rich text, hstore, asset, belongs_to, has_many, has_one, polymorphic, and more

## Quick start

```bash
# Add the gem
bundle add terrazzo

# Install Superglue (if not already set up)
rails g superglue:install

# Install Vite Rails for the default Vite setup.
bundle add vite_rails
bundle exec vite install
# Resolve any package-manager errors from Vite before continuing.

# Add the npm package and frontend dependencies
npm install terrazzo
npm install @radix-ui/react-avatar @radix-ui/react-dialog @radix-ui/react-dropdown-menu \
  @radix-ui/react-label @radix-ui/react-popover @radix-ui/react-select \
  @radix-ui/react-separator @radix-ui/react-slot @radix-ui/react-tooltip \
  class-variance-authority lucide-react tailwindcss@latest
npm install --save-dev @tailwindcss/cli@latest # if your app does not already compile Tailwind

# Install Terrazzo — generates admin namespace, app barrels,
# shadcn metadata/path aliases, and dashboards.
# Uses Vite by default and requires vite_rails.
# For Rails esbuild pass --bundler=esbuild.
rails g terrazzo:install

# Make sure app/assets/stylesheets/admin.css is compiled by Tailwind.
# The installer adds build:admin:css when @tailwindcss/cli 4+ is installed,
# adds a package build script when one is missing, or warns with the setup
# command if no script or tailwindcss-rails setup compiles the Rails-linked
# admin stylesheet.

# Start Rails and Vite
bin/dev
```

Visit `http://localhost:3000/admin` to see your admin panel.

## Documentation

Full docs at **[gohypelab.github.io/terrazzo](https://gohypelab.github.io/terrazzo/)** — covers dashboards, fields, controllers, views, generators, and customization.

## Requirements

- Ruby 3.1+
- Rails 7.1+
- Node.js 18+
- A JS bundler (Vite recommended, esbuild also supported)

## Development and releases

Pull requests and pushes to `main` run the Ruby unit specs, npm package checks,
documentation build, and example app system specs through GitHub Actions.

Terrazzo releases the Ruby gem and npm package from the same version tag. After
updating `lib/terrazzo/version.rb` and `npm/package.json` to matching versions,
push an annotated `v*` tag. The release workflow validates both packages,
publishes missing versions to RubyGems and npm through OIDC trusted publishing,
and creates a GitHub Release with generated notes. Existing registry versions
are skipped, so a partially completed or manually published release can be
retried safely.

See [RELEASING.md](RELEASING.md) for trusted publisher setup, release commands,
and retry instructions.

## Customizing Per-Row Actions

Terrazzo generates Show, Edit, and Destroy action buttons for each row on index pages and has_many tables on show pages.

Override `collection_item_actions` in the resource dashboard to add or replace actions per resource type. Use `super` when you want to keep the default Show/Edit/Destroy actions:

```ruby
class OrderDashboard < Terrazzo::BaseDashboard
  # ...

  def collection_item_actions(resource, view)
    super + [
      { label: "Invoice", url: view.invoice_admin_order_path(resource) },
    ]
  end
end
```

Return a new array instead when you want to fully replace the default actions.

The `view` argument gives access to route helpers. Each action hash supports `label` (String), `url` (String), `method` (optional, e.g. `"delete"`), `confirm` (optional confirmation message for non-GET form actions), and `sg_visit` (set to `false` to bypass SPA navigation).

## Bulk Collection Actions

Override `collection_bulk_actions` to add actions for selected rows on an index page:

```ruby
class OrderDashboard < Terrazzo::BaseDashboard
  def collection_bulk_actions(view)
    [
      { label: "Mark shipped", url: view.bulk_ship_admin_orders_path, method: "post" },
    ]
  end
end
```

Bulk action forms submit selected row IDs as `params[:ids]`. Define the matching collection route and controller action in your app.

## License

MIT
