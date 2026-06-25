# Customizing Page Views

The install generator creates shared page stubs, navigation props, and app-level barrels under `app/views/admin/`. Default React pages, components, fields, and UI primitives come from the `terrazzo` package until you eject the files you want to own.

## File Structure

```
app/views/admin/
├── application/
│   ├── index.jsx                # list view
│   ├── show.jsx                 # detail view
│   ├── new.jsx                  # new form
│   ├── edit.jsx                 # edit form
│   ├── _collection.jsx          # ejected shared collection table partial
│   ├── _form.jsx                # ejected shared form partial
│   └── _navigation.json.props   # sidebar navigation partial
├── components/
│   ├── ui/            # UI barrel and ejected shadcn-style primitives
│   ├── Layout.jsx     # ejected main layout wrapper
│   ├── SearchBar.jsx  # ejected search component
│   └── ...
└── fields/
    ├── string/        # ejected field variants
    ├── boolean/
    └── ...
```

## Overriding Views Per Resource

### Extending the JSON props

To add custom props to a specific resource's JSON response, generate a resource-specific view:

```bash
rails g terrazzo:views:show Product
rails g terrazzo:views:index Product
rails g terrazzo:views:edit Product
```

Each generator ejects a page component and a `.json.props` that calls the gem's base partial. Index also copies `_collection.jsx` when it is missing; edit and new also copy `_form.jsx` when it is missing. Existing app-owned shared partials are preserved. When the matching form page is still Terrazzo's generated package stub, form-page ejection also replaces that counterpart so both pages use the same app-owned form:

```ruby
# app/views/admin/products/show.json.props
json.partial! partial: "terrazzo/application/show_base"
json.inventoryCount @resource.inventory_count
json.onSale @resource.on_sale?
```

The base partials (`show_base`, `index_base`, `edit_base`, `new_base`) provide the standard Terrazzo serialization. Your file just adds to it.

The ejected page and JSX partials let you customize the layout, collection table, or form for that resource — for example, adding custom columns, changing the row layout, or adding extra form fields.

### Overriding the React component

To customize the page component for a specific resource, create a view at that resource's path:

```
app/views/admin/products/index.jsx    → overrides the products index page
app/views/admin/products/show.jsx     → overrides the products show page
```

Your custom component receives the same props as the default (plus any custom props from your `.json.props`):

```jsx
// app/views/admin/products/index.jsx
import { useContent } from "@thoughtbot/superglue"
import { getLayout } from "terrazzo"
import { CollectionToolbarActions } from "../components"

export default function ProductsIndex() {
  const Layout = getLayout()
  const { table, searchBar, filters, pagination, layoutActions, toolbarActions, emptyState, navigation } = useContent()
  return (
    <Layout
      navigation={navigation}
      title="Products"
      actions={
        <div>
          <CollectionToolbarActions actions={layoutActions} />
          <CollectionToolbarActions actions={toolbarActions} />
        </div>
      }>
      {/* your custom layout */}
    </Layout>
  )
}
```

## Re-generating Views

To reset the shared page stubs, app barrels, and navigation props to their defaults:

```bash
rails g terrazzo:views
```

This will overwrite those generated files. Use `rails g terrazzo:eject ...` for individual pages, components, fields, or UI primitives that you want to own locally.
Ejection replaces Terrazzo's generated package stubs directly; customized app-owned files still use Rails' normal overwrite prompt.
Files copied only as dependencies of the requested ejection are skipped when they already exist, so later ejections do not clobber app-owned dependency files or assume their default exports. Eject that dependency directly when you want to replace and register it.

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
import { getLayout } from "terrazzo"

export default function ReportsIndex() {
  const Layout = getLayout()
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

### 5. Register the component

Add an entry to `app/javascript/admin/custom_page_mapping.js`. Resource-specific Terrazzo generators use `generated_page_mapping.js`, so this manual manifest is safe to edit directly.

```javascript
import ReportsIndex from "../../views/admin/reports/index"

export const customPageMapping = {
  'admin/reports/index': ReportsIndex,
}
```

`page_to_page_mapping.js` imports both `generated_page_mapping.js` and `custom_page_mapping.js`, then merges them with the built-in application pages. Manual custom mappings win over generated mappings when keys overlap.

## Custom Layout

The gem's page components use a `Layout` component that wraps every page with a sidebar, header, and flash messages. To replace it globally without ejecting every page, register a custom Layout in your entry point:

```js
// app/javascript/admin/application.jsx
import { setLayout } from "terrazzo";
import { CustomLayout } from "../../views/admin/components/CustomLayout";

setLayout(CustomLayout);
```

Your custom Layout must accept the same props as the default:

```jsx
function CustomLayout({ navigation, title, actions, children }) {
  return (
    // your custom shell — sidebar, header, etc.
  );
}
```

All page components — both the gem's built-in pages and ejected pages — will automatically use your custom Layout. If no custom Layout is registered, the gem's default Layout is used.

Ejected pages use `getLayout()` (also exported from `terrazzo`) to resolve the active Layout at render time, so they respect `setLayout` without any extra wiring.

Running `rails g terrazzo:eject components/Layout` copies the default layout and any missing local dependencies, then updates `app/views/admin/components/index.js` to call `setLayout(Layout)` for you. The generated admin entrypoint imports that barrel before rendering.

The default Layout is also available as `DefaultLayout` from `terrazzo/components`, so you can extend it:

```jsx
import { DefaultLayout } from "terrazzo/components";

function CustomLayout(props) {
  return (
    <DefaultLayout {...props}>
      <MyDrawerPanel />
      {props.children}
    </DefaultLayout>
  );
}
```

## Custom Components

Default Terrazzo pages resolve overridable components through a component registry. Running a component ejection command copies the component source into your app and updates `app/views/admin/components/index.js` to register it:

```bash
rails g terrazzo:eject components/ResourceTable
rails g terrazzo:eject components/SearchBar
rails g terrazzo:eject components/CollectionToolbarActions
```

The generated admin entrypoint imports the components barrel before rendering, so package pages will use registered local overrides for components such as `ResourceTable`, `SearchBar`, `CollectionFilters`, `Pagination`, `SortableHeader`, `CollectionItemActions`, `CollectionToolbarActions`, `HasManyPagination`, `AppSidebar`, `SiteHeader`, and `FlashMessages`. `CollectionToolbarActions` renders dashboard-provided header actions and the default show-page Back/Edit/Delete actions.

## Customizing the Sidebar Navigation

The sidebar navigation is rendered by a shared partial at `app/views/admin/application/_navigation.json.props`. This partial is included automatically by the layout, so you don't need to add it to each page template.

For resource labels, grouping, ordering, and hiding, prefer dashboard constants:

```ruby
class ProductDashboard < Terrazzo::BaseDashboard
  NAVIGATION_LABEL = "Catalog"
  NAVIGATION_GROUP = "Commerce"
  NAVIGATION_GROUP_ORDER = 10
  NAVIGATION_ORDER = 20
end
```

Set `SHOW_IN_NAVIGATION = false` to hide a resource from the generated sidebar.

### Adding Custom Links

Eject the navigation partial when you need non-resource links or fully custom sidebar data:

```bash
rails g terrazzo:eject navigation
```

```ruby
# app/views/admin/application/_navigation.json.props
resources = Terrazzo::Namespace.new(namespace).navigation_resources

groups = [
  {
    label: "Admin",
    items: [
      { label: "Dashboard", path: admin_root_path, active: controller_path == "admin/dashboard" },
    ],
  },
  {
    label: "Resources",
    items: resources.map do |r|
      {
        label: r.navigation_label,
        path: url_for(controller: "/#{r.controller_path}", action: :index, only_path: true),
        active: r.controller_path == controller_path,
      }
    end,
  },
]

json.array! groups do |group|
  json.label group[:label]
  json.items do
    json.array! group[:items] do |item|
      json.label item[:label]
      json.path item[:path]
      json.active item[:active]
    end
  end
end
```

## SPA Navigation

Terrazzo uses [Superglue](https://github.com/thoughtbot/superglue) for client-side navigation:

- **Full navigation** — links with `data-sg-visit` trigger a full page transition (e.g., sidebar links, show/edit links)
- **Partial updates** — links with `data-sg-remote` update only part of the page (e.g., search, sort, pagination)

Pagination and sort links include `props_at` parameters so the server only renders the relevant subtrees, keeping updates fast.
