# Generators

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
- `belongs_to` polymorphic associations → `Field::Polymorphic`
- `has_many` associations → `Field::HasMany`
- `has_one` associations → `Field::HasOne`

`FORM_ATTRIBUTES` excludes `id`, `created_at`, and `updated_at`. `COLLECTION_ATTRIBUTES` is limited to 4 attributes.

## `terrazzo:views`

Regenerates all view components from the gem's templates.

```bash
rails g terrazzo:views
```

Use this after upgrading the gem to get the latest component versions. **This will overwrite your local customizations.**

## `terrazzo:views:index`, `terrazzo:views:show`, `terrazzo:views:new`, `terrazzo:views:edit`

Ejects a view for customization. Without a resource argument, ejects the shared JSX page component. With a resource argument, ejects a complete resource-specific view: the page JSX, its associated partial (`_collection.jsx` or `_form.jsx`), and a `.json.props` that extends the base serialization.

```bash
# Eject the shared JSX page component
rails g terrazzo:views:show

# Eject a resource-specific view
rails g terrazzo:views:show User
rails g terrazzo:views:index Order
rails g terrazzo:views:edit Product
rails g terrazzo:views:new BlogPost
```

When ejecting for a resource, the generator creates a complete set of files:

- `terrazzo:views:index User` → `index.jsx` + `_collection.jsx` + `index.json.props`
- `terrazzo:views:edit User` → `edit.jsx` + `_form.jsx` + `edit.json.props`
- `terrazzo:views:new User` → `new.jsx` + `_form.jsx` + `new.json.props`
- `terrazzo:views:show User` → `show.json.props`

Because `edit` and `new` share the same `_form.jsx` partial via a relative import, ejecting one without the other means the non-ejected view continues using the built-in form. To keep them in sync, the `edit` and `new` generators will prompt you to also eject the counterpart view if it hasn't been ejected already.

The ejected `.json.props` calls the gem's base partial and leaves room for custom props:

```ruby
# app/views/admin/users/show.json.props
json.partial! partial: "terrazzo/application/show_base"
# Add custom props below:
# json.customProp @resource.some_method
```

### Options

| Option | Default | Description |
|--------|---------|-------------|
| `--namespace` | `admin` | Admin namespace |

## `terrazzo:routes`

Generates the admin namespace routes.

```bash
rails g terrazzo:routes
```

Inserts a `namespace :admin` block with resource routes and a root route into your `config/routes.rb`.
