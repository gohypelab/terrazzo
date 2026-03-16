# Example App

Demo Rails 8 + React SPA showcasing the Terrazzo gem. An e-commerce admin panel with customers, orders, products, payments, and blog posts.

## Quick Start

```bash
cd spec/example_app
bin/setup              # Install deps, prepare DB
bin/dev                # Start Rails server on :3000
npm run build:watch    # Watch mode for JS + CSS (separate terminal)
```

Visit `http://localhost:3000/admin`.

## Tech Stack

- **Backend:** Rails 8.1, SQLite, Puma
- **Frontend:** React 18, Redux Toolkit, @thoughtbot/superglue, Tailwind CSS 4, shadcn/ui
- **Build:** esbuild (JS), @tailwindcss/cli (CSS), Propshaft (asset pipeline)
- **Testing:** RSpec, Factory Bot
- **Icons:** Lucide (lucide-react)

## Architecture

- Controllers in `app/controllers/admin/` inherit from `Terrazzo::ApplicationController`
- Dashboards in `app/dashboards/` define field types and CRUD config
- No `.erb` view files — JSON props rendered via `.json.props` templates from the gem
- React page views live in `app/views/admin/application/` following Superglue conventions
- Shared components and UI primitives live in `app/views/admin/components/`
- Field renderers live in `app/views/admin/fields/`
- JS entry point: `app/javascript/admin/application.js`
- Page-to-component mapping: `app/javascript/admin/page_to_page_mapping.js`
- The `terrazzo` npm package provides only utilities (`cn`, `truncate`, `formatDate/DateTime/Time`), hooks (`useIsMobile`), store helpers (`useAppSelector`), and the field registry API — all React components are local

## Key Paths

- `app/controllers/admin/` — Resource controllers
- `app/dashboards/` — Dashboard definitions (field DSL)
- `app/models/` — ActiveRecord models
- `app/views/admin/application/` — Page views (index, show, new, edit, _form)
- `app/views/admin/components/` — Shared components (Layout, AppSidebar, SearchBar, etc.)
- `app/views/admin/components/ui/` — shadcn UI primitives (Button, Input, Table, etc.)
- `app/views/admin/fields/` — Field renderers (16 types × 3 modes each)
- `app/javascript/admin/` — Bundler entry point, page mapping, visit helper, Redux slices
- `app/assets/stylesheets/admin.css` — Tailwind theme config (oklch colors)
- `esbuild.config.mjs` — JS build config with dedupe plugin
- `config/routes.rb` — All resources under `namespace :admin`
- `db/seeds.rb` — Sample data (customers, products, orders, blog posts)

## Dependencies

The gem and npm package are loaded from local paths:
- **Gem:** `gem "terrazzo", path: "../.."` (repo root)
- **NPM:** `"terrazzo": "file:../../npm"` (repo `npm/` dir)

The npm package is a slim runtime (utilities + hooks only). UI dependencies (Radix, cva, lucide-react) are direct dependencies of the example app.

## Commands

| Task | Command |
|------|---------|
| Setup | `bin/setup` |
| Setup with DB reset | `bin/setup --reset` |
| Dev server | `bin/dev` |
| Stop server | `bin/stop` |
| Build assets | `npm run build` |
| Watch assets | `npm run build:watch` |
| Build CSS only | `npm run build:css` |
| Run tests | `bundle exec rspec` |
| DB reset + seed | `bin/rails db:reset` |
| Rails console | `bin/rails console` |

## Database

SQLite stored in `storage/`. Schema has 12+ tables including `customers`, `orders`, `products`, `line_items`, `payments`, `series`, `pages`, `product_meta_tags`, `countries`, `blog_posts`, `blog_tags`, plus Active Storage and Action Text tables.

## Routes

All admin resources namespaced under `/admin`:
- `/admin/customers` (root)
- `/admin/orders`, `/admin/products`, `/admin/payments` (index + show only)
- `/admin/series`, `/admin/pages`, `/admin/product_meta_tags`
- `/admin/blog/posts`, `/admin/blog/tags`
