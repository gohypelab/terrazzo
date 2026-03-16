# Generators Reference

## `terrazzo:install`

Sets up Terrazzo in your Rails app.

```bash
rails g terrazzo:install
```

### Options

| Option | Default | Description |
|--------|---------|-------------|
| `--namespace` | `admin` | Admin namespace (controller prefix, route scope, JS directory) |
| `--bundler` | `vite` | JavaScript bundler. `vite` uses Vite asset tags and `import.meta.glob` for auto-discovery of page components; `esbuild` and `sprockets` use explicit imports with `javascript_include_tag` |

```bash
# Vite (default)
rails g terrazzo:install

# esbuild
rails g terrazzo:install --bundler=esbuild

# Sprockets
rails g terrazzo:install --bundler=sprockets

# Custom namespace
rails g terrazzo:install --namespace=backstage
```

Creates:
- Admin Superglue infrastructure (entry point, page mapping, visit handler, flash slice, layouts)
- Admin application controller
- Admin routes namespace
- Dashboards for all existing `ApplicationRecord` models
- UI components and field renderers

## `terrazzo:dashboard`

Generates a dashboard for a specific model.

```bash
rails g terrazzo:dashboard Product
rails g terrazzo:dashboard Blog::Post
```

### Options

| Option | Default | Description |
|--------|---------|-------------|
| `--namespace` | `admin` | Admin namespace |
| `--bundler` | `vite` | JavaScript bundler. With `esbuild` or `sprockets`, appends entries to `page_to_page_mapping.js`. With `vite`, skips this (components are auto-discovered via `import.meta.glob`) |

Creates:
- `app/dashboards/product_dashboard.rb`
- `app/controllers/admin/products_controller.rb`
- Appends entries to `page_to_page_mapping.js` (esbuild/Sprockets only)

The generator inspects your model's columns and associations:
- String columns → `Field::String`
- Integer/float columns → `Field::Number`
- Boolean columns → `Field::Boolean`
- Date columns → `Field::Date`
- DateTime columns → `Field::DateTime`
- Text columns → `Field::Text`
- Enums → `Field::Select` with collection
- `belongs_to` associations → `Field::BelongsTo`
- `has_many` associations → `Field::HasMany`

`FORM_ATTRIBUTES` excludes `id`, `created_at`, and `updated_at`. `COLLECTION_ATTRIBUTES` is limited to 4 attributes.

## `terrazzo:views`

Regenerates all view components from the gem's templates.

```bash
rails g terrazzo:views
```

Use this after upgrading the gem to get the latest component versions. **This will overwrite your local customizations.**

## `terrazzo:routes`

Generates the admin namespace routes.

```bash
rails g terrazzo:routes
```

Inserts a `namespace :admin` block with resource routes and a root route into your `config/routes.rb`.
