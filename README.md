# Terrazzo

A drop-in admin panel for Rails apps. Uses the [Administrate](https://github.com/thoughtbot/administrate) dashboard DSL with a React SPA frontend powered by [Superglue](https://github.com/thoughtbot/superglue).

- **Familiar DSL** — same `ATTRIBUTE_TYPES`, `COLLECTION_ATTRIBUTES`, `FORM_ATTRIBUTES` you already know
- **React SPA** — search, sort, and paginate without full page reloads, no separate API needed
- **shadcn/ui + Tailwind** — every generated component lives in your app and is fully editable
- **16 field types** — string, number, boolean, date/time, email, URL, select, rich text, belongs_to, has_many, has_one, polymorphic, and more

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

Full docs at **[wengzilla.github.io/terrazzo](https://wengzilla.github.io/terrazzo/)** — covers dashboards, fields, controllers, views, generators, and customization.

## Requirements

- Ruby 3.1+
- Rails 7.1+
- Node.js 18+
- A JS bundler (Vite recommended, esbuild and Sprockets also supported)

## License

MIT
