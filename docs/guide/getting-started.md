# Getting Started

## 1. Add the gem

```ruby
# Gemfile
gem "super_admin"
```

```bash
bundle install
```

## 2. Add the npm package

```bash
yarn add super-admin
# or
npm install super-admin
```

The `super-admin` npm package is a slim runtime that provides utilities (`cn`, `truncate`, `formatDate/DateTime/Time`), hooks (`useIsMobile`), and the field registry API. All React components (UI primitives, pages, fields) are copied into your project by the install generator.

## 3. Install frontend dependencies

The generated components use shadcn/ui patterns, so you'll need these packages:

```bash
yarn add @radix-ui/react-avatar @radix-ui/react-dialog @radix-ui/react-dropdown-menu \
  @radix-ui/react-popover @radix-ui/react-separator @radix-ui/react-slot \
  @radix-ui/react-tooltip class-variance-authority clsx lucide-react tailwind-merge
```

## 4. Install Superglue (if you haven't already)

SuperAdmin is built on top of [Superglue](https://github.com/thoughtbot/superglue). If your app already uses Superglue, skip to step 5.

```bash
rails g superglue:install
```

This sets up the core Superglue infrastructure:

- React/Redux application entry point (`app/javascript/application.js`)
- Page-to-page mapping, store, and application visit handler
- Flash message Redux slice
- HTML and JSON layouts
- `config/initializers/superglue.rb`
- JS dependencies (`react`, `react-dom`, `@reduxjs/toolkit`, `react-redux`, `@thoughtbot/superglue`)

## 5. Run the SuperAdmin install generator

```bash
rails g super_admin:install
```

By default the generator assumes **Vite**. If your app uses Sprockets instead:

```bash
rails g super_admin:install --bundler=sprockets
```

This creates an isolated admin namespace alongside your existing app — it won't conflict with any existing Superglue pages or controllers:

**Admin Superglue infrastructure** (namespaced under `admin/`):
- `app/javascript/admin/application.jsx` — separate Superglue entry point for the admin
- `app/javascript/admin/page_to_page_mapping.js` — maps admin pages to React components
- `app/javascript/admin/application_visit.js` — visit/remote factory
- `app/javascript/admin/slices/flash.js` — flash message Redux slice
- `app/views/layouts/admin/superglue.html.erb` — admin HTML layout
- `app/views/layouts/admin/application.json.props` — admin JSON props layout

**Admin controllers and routes:**
- `app/controllers/admin/application_controller.rb` — inherits from `SuperAdmin::ApplicationController`
- `config/routes.rb` — adds an `admin` namespace with a root route

**Admin UI components and views:**
- `app/views/admin/application/` — page views (index, show, new, edit, _form)
- `app/views/admin/components/` — shared components (Layout, AppSidebar, SearchBar, etc.)
- `app/views/admin/components/ui/` — shadcn UI primitives (Button, Input, Table, etc.)
- `app/views/admin/fields/` — field renderers for all 16 field types

**Dashboards** — automatically generates a dashboard for each `ApplicationRecord` model it finds.

## 6. Generate additional dashboards

The install generator (step 5) automatically creates dashboards for all existing `ApplicationRecord` models. To add dashboards for new models later:

```bash
rails g super_admin:dashboard Product
rails g super_admin:dashboard Customer
rails g super_admin:dashboard Order
```

Each generates:

- `app/dashboards/product_dashboard.rb` — field definitions
- `app/controllers/admin/products_controller.rb` — inherits from your admin `ApplicationController`
- Updates `page_to_page_mapping.js` with the new resource's pages

## 7. Start the server

```bash
bin/dev
```

Visit `http://localhost:3000/admin` to see your admin panel.
