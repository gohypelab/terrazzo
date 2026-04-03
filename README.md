# Terrazzo

A drop-in admin panel for Rails apps. Uses the [Administrate](https://github.com/thoughtbot/administrate) dashboard DSL with a React SPA frontend powered by [Superglue](https://github.com/thoughtbot/superglue).

- **Familiar DSL** — same `ATTRIBUTE_TYPES`, `COLLECTION_ATTRIBUTES`, `FORM_ATTRIBUTES` you already know
- **React SPA** — search, sort, and paginate without full page reloads, no separate API needed
- **shadcn/ui + Tailwind** — every generated component lives in your app and is fully editable
- **17 field types** — string, number, money, boolean, date/time, email, URL, select, rich text, belongs_to, has_many, has_one, polymorphic, and more

## Quick start

```bash
# Add the gem and npm package
bundle add terrazzo
npm install terrazzo

# Install Superglue (if not already set up)
rails g superglue:install

# Install Terrazzo — generates admin namespace, UI components, and dashboards
# Uses Vite by default; for Sprockets pass --bundler=sprockets
rails g terrazzo:install

# Start the server
bin/dev
```

Visit `http://localhost:3000/admin` to see your admin panel.

## Documentation

Full docs at **[gohypelab.github.io/terrazzo](https://gohypelab.github.io/terrazzo/)** — covers dashboards, fields, controllers, views, generators, and customization.

## Requirements

- Ruby 3.1+
- Rails 7.1+
- Node.js 18+
- A JS bundler (Vite recommended, esbuild and Sprockets also supported)

## Customizing Per-Row Actions

Terrazzo generates Show, Edit, and Destroy action buttons for each row on index pages and has_many tables on show pages. These are driven by the `collection_item_actions(resource)` helper (defined in `Terrazzo::CollectionActionsHelper`).

Override in your controller helper to customize actions per resource type:

```ruby
module Admin
  module CollectionActionsHelper
    def collection_item_actions(resource)
      actions = super
      if resource.is_a?(User)
        actions << { label: "Ghost", url: admin_user_ghost_path(user_id: resource.id) }
      end
      actions
    end
  end
end
```

Each action hash supports `label` (String), `url` (String), `method` (optional, e.g. `"delete"`), and `confirm` (optional confirmation message).

## License

MIT
