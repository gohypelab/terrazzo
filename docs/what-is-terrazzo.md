# What is Terrazzo?

Terrazzo is a **Rails admin framework** that replaces Administrate's server-rendered ERB views with a **React single-page application** powered by [Superglue](https://github.com/thoughtbot/superglue).

## Why Terrazzo?

Administrate is great, but its ERB-based views can feel limiting when you want rich, interactive admin interfaces. Terrazzo keeps the parts that work well — the dashboard DSL — and swaps the frontend for a modern React SPA.

- **Same DSL** — `ATTRIBUTE_TYPES`, `COLLECTION_ATTRIBUTES`, `FORM_ATTRIBUTES`, `SHOW_PAGE_ATTRIBUTES` all work the same way.
- **No separate API** — Superglue lets your Rails views serve both JSON props and React components. No GraphQL or REST API to maintain.
- **Full SPA experience** — Search, sort, and paginate without full page reloads. Browser back/forward just works.
- **Your code, your rules** — Terrazzo installs app-level barrels and shared page stubs, then lets you eject supported starter files when you want to own and edit the React source directly.

## How It Works

Terrazzo is two packages:

1. **`terrazzo` gem** — Provides the dashboard DSL, field types, generic `.json.props` templates, controllers, and Rails generators.
2. **`terrazzo` npm package** — Provides the default React pages/components, utilities (`cn`, `truncate`, `formatDate`, `csrfToken`), hooks (`useIsMobile`), and the field registry API.

When you run the install generator, it creates admin entrypoints, page mapping, shared page stubs, and app-level barrels for fields, components, and UI primitives. The default React implementation comes from the `terrazzo` package; ejection copies supported starter files into your app when you need local ownership.

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
