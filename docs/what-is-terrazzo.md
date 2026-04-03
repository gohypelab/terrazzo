# What is Terrazzo?

Terrazzo is a **Rails admin framework** that replaces Administrate's server-rendered ERB views with a **React single-page application** powered by [Superglue](https://github.com/thoughtbot/superglue).

## Why Terrazzo?

Administrate is great, but its ERB-based views can feel limiting when you want rich, interactive admin interfaces. Terrazzo keeps the parts that work well — the dashboard DSL — and swaps the frontend for a modern React SPA.

- **Same DSL** — `ATTRIBUTE_TYPES`, `COLLECTION_ATTRIBUTES`, `FORM_ATTRIBUTES`, `SHOW_PAGE_ATTRIBUTES` all work the same way.
- **No separate API** — Superglue lets your Rails views serve both JSON props and React components. No GraphQL or REST API to maintain.
- **Full SPA experience** — Search, sort, and paginate without full page reloads. Browser back/forward just works.
- **Your code, your rules** — All generated views and components are copied into your app. Edit them directly — no monkey-patching or complex override systems.

## How It Works

Terrazzo is two packages:

1. **`terrazzo` gem** — Provides the dashboard DSL, field types, generic `.json.props` templates, controllers, and Rails generators.
2. **`terrazzo` npm package** — A slim runtime with utilities (`cn`, `truncate`, `formatDate`), hooks (`useIsMobile`), and the field registry API.

When you run the install generator, it copies all React components (UI primitives, page views, field renderers) into your app. From that point, they're yours to customize.

## Architecture

```
Browser ←→ React SPA (Superglue) ←→ Rails Controller ←→ Dashboard ←→ Model
                                          ↓
                                   .json.props templates
                                   (field.serialize_value)
```

1. Rails controllers use dashboards to determine which fields to render.
2. `.json.props` templates call `field.serialize_value(mode)` to produce JSON.
3. Superglue delivers the JSON to React components on the client.
4. React components use `FieldRenderer` to dispatch to the right field component based on `fieldType` and `mode`.

## Requirements

- Ruby 3.1+
- Rails 7.1+
- Node.js 18+
- A JS bundler (esbuild or Vite)
