# Terrazzo

A drop-in admin panel for Rails apps. Uses the [Administrate](https://github.com/thoughtbot/administrate) dashboard DSL with a React SPA frontend powered by [Superglue](https://github.com/thoughtbot/superglue).

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

## Customizing Per-Row Actions

Terrazzo generates Show, Edit, and Destroy action buttons for each row on index pages and has_many tables on show pages.

Override `collection_item_actions` in the resource dashboard to customize actions per resource type:

```ruby
class OrderDashboard < Terrazzo::BaseDashboard
  # ...

  def collection_item_actions(resource, view)
    [
      { label: "View Order", url: view.admin_order_path(resource) },
      { label: "Edit", url: view.edit_admin_order_path(resource) },
      { label: "Invoice", url: view.invoice_admin_order_path(resource) },
    ]
  end
end
```

The `view` argument gives access to route helpers. Each action hash supports `label` (String), `url` (String), `method` (optional, e.g. `"delete"`), `confirm` (optional confirmation message for non-GET form actions), and `sg_visit` (set to `false` to bypass SPA navigation).

## License

MIT
