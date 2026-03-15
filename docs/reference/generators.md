# Generators Reference

## `super_admin:install`

Sets up SuperAdmin in your Rails app.

```bash
rails g super_admin:install
```

### Options

| Option | Default | Description |
|--------|---------|-------------|
| `--namespace` | `admin` | Admin namespace (controller prefix, route scope, JS directory) |
| `--bundler` | `vite` | JavaScript bundler. `vite` uses Vite asset tags and `import.meta.glob` for auto-discovery of page components; `esbuild` and `sprockets` use explicit imports with `javascript_include_tag` |

```bash
# Vite (default)
rails g super_admin:install

# esbuild
rails g super_admin:install --bundler=esbuild

# Sprockets
rails g super_admin:install --bundler=sprockets

# Custom namespace
rails g super_admin:install --namespace=backstage
```

Creates:
- Admin Superglue infrastructure (entry point, page mapping, visit handler, flash slice, layouts)
- Admin application controller
- Admin routes namespace
- Dashboards for all existing `ApplicationRecord` models
- UI components and field renderers

## `super_admin:dashboard`

Generates a dashboard for a specific model.

```bash
rails g super_admin:dashboard Product
rails g super_admin:dashboard Blog::Post
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

## `super_admin:views`

Regenerates all view components from the gem's templates.

```bash
rails g super_admin:views
```

Use this after upgrading the gem to get the latest component versions. **This will overwrite your local customizations.**

## `super_admin:routes`

Generates the admin namespace routes.

```bash
rails g super_admin:routes
```

Inserts a `namespace :admin` block with resource routes and a root route into your `config/routes.rb`.
