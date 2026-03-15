# Views & Components

All generated views and components live in your app at `app/views/admin/` and can be edited directly.

## File Structure

```
app/views/admin/
├── application/
│   ├── index.jsx      # list view
│   ├── show.jsx       # detail view
│   ├── new.jsx        # new form
│   ├── edit.jsx       # edit form
│   └── _form.jsx      # shared form partial
├── components/
│   ├── ui/            # shadcn UI primitives
│   ├── Layout.jsx     # main layout wrapper
│   ├── SearchBar.jsx
│   └── ...
└── fields/
    ├── string/        # each field type has Index, Show, and Form variants
    ├── boolean/
    └── ...
```

## Overriding Views Per Resource

To customize a page for a specific resource, create a view at that resource's path:

```
app/views/admin/products/index.jsx    → overrides the products index page
app/views/admin/products/show.jsx     → overrides the products show page
```

Your custom component receives the same props as the default:

```jsx
// app/views/admin/products/index.jsx
import { useContent } from "@thoughtbot/superglue"
import { Layout } from "../components/Layout"

export default function ProductsIndex() {
  const { table, searchBar, pagination, navigation } = useContent()
  return (
    <Layout navigation={navigation} title="Products">
      {/* your custom layout */}
    </Layout>
  )
}
```

## Re-generating Views

To reset all generated components to their defaults (e.g., after upgrading the gem):

```bash
rails g super_admin:views
```

This will overwrite your local copies with the latest versions from the gem.

## Custom Pages

You can add pages beyond the standard CRUD views — for example, a dashboard overview or a reports page.

### 1. Add a controller action

```ruby
# app/controllers/admin/reports_controller.rb
class Admin::ReportsController < Admin::ApplicationController
  superglue_template "admin/reports"

  def index
    @data = # ...
  end
end
```

Setting `superglue_template "admin/reports"` tells Superglue to look for components under `admin/reports/` instead of the shared `admin/application/` templates.

### 2. Create a `.json.props` template

```ruby
# app/views/admin/reports/index.json.props
json.pageTitle "Reports"
json.data @data
# ... any props your component needs

json.navigation do
  json.array! SuperAdmin::Namespace.new(namespace).resources_with_index_route do |nav_resource|
    json.label nav_resource.resource_name.humanize.pluralize
    json.path url_for(controller: "/#{nav_resource.controller_path}", action: :index, only_path: true)
    json.active nav_resource.controller_path == controller_path
  end
end
```

### 3. Create a React component

```jsx
// app/views/admin/reports/index.jsx
import { useContent } from "@thoughtbot/superglue"
import { Layout } from "../components/Layout"

export default function ReportsIndex() {
  const { pageTitle, data, navigation } = useContent()
  return (
    <Layout navigation={navigation} title={pageTitle}>
      {/* your custom page */}
    </Layout>
  )
}
```

### 4. Add a route

```ruby
# config/routes.rb
namespace :admin do
  resources :reports, only: [:index]
end
```

### 5. Register the component (esbuild/Sprockets only)

If you're using **Vite**, the component is auto-discovered via `import.meta.glob` — no extra step needed.

If you're using **esbuild or Sprockets**, add an entry to `page_to_page_mapping.js`:

```javascript
import ReportsIndex from "../../views/admin/reports/index"

export const pageToPageMapping = {
  // ... existing entries
  'admin/reports/index': ReportsIndex,
}
```

## SPA Navigation

SuperAdmin uses [Superglue](https://github.com/thoughtbot/superglue) for client-side navigation:

- **Full navigation** — links with `data-sg-visit` trigger a full page transition (e.g., sidebar links, show/edit links)
- **Partial updates** — links with `data-sg-remote` update only part of the page (e.g., search, sort, pagination)

Pagination and sort links include `props_at` parameters so the server only renders the relevant subtrees, keeping updates fast.
