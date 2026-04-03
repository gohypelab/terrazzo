# Customizing Page Views

All generated views and components live in your app at `app/views/admin/` and can be edited directly.

## File Structure

```
app/views/admin/
├── application/
│   ├── index.jsx                # list view
│   ├── show.jsx                 # detail view
│   ├── new.jsx                  # new form
│   ├── edit.jsx                 # edit form
│   ├── _form.jsx                # shared form partial
│   └── _navigation.json.props   # sidebar navigation partial
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
rails g terrazzo:views
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
# Navigation is automatically provided by the layout partial
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

## Customizing the Sidebar Navigation

The sidebar navigation is rendered by a shared partial at `app/views/admin/application/_navigation.json.props`. This partial is included automatically by the layout, so you don't need to add it to each page template.

To customize the navigation (e.g., add custom links, reorder items, or group resources), edit the partial directly.

### Adding custom links

Build an array of items and pass it to `json.array!`:

```ruby
# app/views/admin/application/_navigation.json.props
resources = Terrazzo::Namespace.new(namespace).resources_with_index_route

items = [
  { label: "Dashboard", path: admin_root_path, active: controller_path == "admin/dashboard" },
]

json.array! items do |item|
  json.label item[:label]
  json.path item[:path]
  json.active item[:active]
end

json.array! resources do |nav_resource|
  json.label nav_resource.resource_name.humanize.pluralize
  json.path url_for(controller: "/#{nav_resource.controller_path}", action: :index, only_path: true)
  json.active nav_resource.controller_path == controller_path
end
```

### Grouping resources into sections

You can split navigation into groups by changing the partial to output grouped data, then updating the sidebar component to render each group separately.

**1. Update the navigation partial** to return groups with labels and items:

```ruby
# app/views/admin/application/_navigation.json.props
resources = Terrazzo::Namespace.new(namespace).resources_with_index_route
blog_resources, main_resources = resources.partition do |r|
  r.controller_path.start_with?("admin/blog")
end

groups = [
  { label: "Resources", resources: main_resources },
  { label: "Blog", resources: blog_resources },
]

json.array! groups do |group|
  json.label group[:label]
  json.items do
    json.array! group[:resources] do |r|
      json.label r.resource_name.humanize.pluralize
      json.path url_for(controller: "/#{r.controller_path}", action: :index, only_path: true)
      json.active r.controller_path == controller_path
    end
  end
end
```

**2. Update `app-sidebar.jsx`** to render each group as a separate section:

```jsx
<SidebarContent>
  {navigation.map((group) =>
    <SidebarGroup key={group.label}>
      <SidebarGroupLabel>{group.label}</SidebarGroupLabel>
      <SidebarGroupContent>
        <SidebarMenu>
          {group.items.map((item) =>
            <SidebarMenuItem key={item.path}>
              <SidebarMenuButton
                asChild
                isActive={item.active}
                tooltip={item.label}>
                <a href={item.path} data-sg-visit>
                  <span>{item.label}</span>
                </a>
              </SidebarMenuButton>
            </SidebarMenuItem>
          )}
        </SidebarMenu>
      </SidebarGroupContent>
    </SidebarGroup>
  )}
</SidebarContent>
```

## SPA Navigation

Terrazzo uses [Superglue](https://github.com/thoughtbot/superglue) for client-side navigation:

- **Full navigation** — links with `data-sg-visit` trigger a full page transition (e.g., sidebar links, show/edit links)
- **Partial updates** — links with `data-sg-remote` update only part of the page (e.g., search, sort, pagination)

Pagination and sort links include `props_at` parameters so the server only renders the relevant subtrees, keeping updates fast.
