# Customizing Dashboards

Dashboards define which fields appear on each page of your admin panel. The DSL is identical to [Administrate](https://administrate-demo-prerelease.herokuapp.com/customizing_dashboards).

## Basic Structure

```ruby
# app/dashboards/product_dashboard.rb
class ProductDashboard < Terrazzo::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::String,
    name: Field::String,
    price: Field::Number.with_options(prefix: "$", decimals: 2),
    description: Field::Text,
    category: Field::Select.with_options(
      collection: %w[Electronics Books Clothing]
    ),
    customer: Field::BelongsTo,
    tags: Field::HasMany,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
  }.freeze

  COLLECTION_ATTRIBUTES = %i[id name price category].freeze
  SHOW_PAGE_ATTRIBUTES = %i[id name price description category customer tags created_at updated_at].freeze
  FORM_ATTRIBUTES = %i[name price description category customer tags].freeze
end
```

## `ATTRIBUTE_TYPES`

A hash mapping attribute names to field types. Every attribute you want to display anywhere must be listed here.

See [Customizing Fields](./customizing-fields) for the full list of field types and their options.

## `COLLECTION_ATTRIBUTES`

An array of attributes shown on the index (list) page. Keep this short — typically 3-5 columns.

## `SHOW_PAGE_ATTRIBUTES`

An array of attributes shown on the detail page.

## `FORM_ATTRIBUTES`

An array of attributes shown on the new/edit form. You can also define separate lists for create and update:

```ruby
FORM_ATTRIBUTES_NEW = %i[name email password].freeze
FORM_ATTRIBUTES_EDIT = %i[name email].freeze
```

When these are defined, they take precedence over `FORM_ATTRIBUTES` for their respective actions.

## `COLLECTION_FILTERS`

Named filters for the index page:

```ruby
COLLECTION_FILTERS = {
  active: ->(resources) { resources.where(active: true) },
  recent: ->(resources) { resources.where("created_at > ?", 30.days.ago) },
}.freeze
```

Filters that only need the resource relation are rendered as index facets automatically. Filters that require a value, such as `->(resources, value) { ... }`, are supported through the `filter` and `filter_value` params but are not rendered as one-click facets by default.

Override `collection_filter_label` to customize facet text:

```ruby
def collection_filter_label(filter_name)
  filter_name == :recent ? "Recently added" : super
end
```

Override `collection_filter_options` when you need full control over which filters appear as facets:

```ruby
def collection_filter_options(_view)
  [
    { label: "Recently added", value: "recent" },
    { label: "VIP", value: "vip" },
  ]
end
```

## Display Name

Override `display_resource` to customize how a record is shown in links, titles, and association dropdowns:

```ruby
def display_resource(resource)
  resource.name
end
```

The default is `"ClassName #id"`.

## Attribute Labels and Hints

Override `attribute_label` to rename fields across index headers, show pages, forms, nested `has_many` tables, and CSV exports:

```ruby
def attribute_label(attribute, context = nil)
  return "SKU" if attribute == :sku
  return "Customer email" if attribute == :email && context == :csv

  super
end
```

The `context` argument is one of `:index`, `:show`, `:form`, or `:csv`.

Override `attribute_hint` to show supporting text on forms and show pages:

```ruby
def attribute_hint(attribute, context = nil)
  return "Used for receipts and account notifications." if attribute == :email && context == :form

  super
end
```

## Collection Cell Options

Use `collection_cell_options` when a table cell needs presentation metadata without ejecting the index page:

```ruby
def collection_cell_options(attribute, resource)
  return {} unless attribute == :status

  {
    class_name: resource.overdue? ? "text-destructive font-medium" : "text-muted-foreground",
    tone: resource.overdue? ? "danger" : "neutral",
  }
end
```

The default table applies `class_name` / `className` to the `<td>`. Other keys are serialized under `cellOptions.meta` so custom index field components can use them.

## Custom Row Actions

By default, each row on the index page shows Show, Edit, and Destroy buttons. Override `collection_item_actions` in your dashboard to customize these per resource type:

```ruby
class OrderDashboard < Terrazzo::BaseDashboard
  # ...

  def collection_item_actions(resource, view)
    [
      { label: "View Order", url: view.admin_order_path(resource) },
      { label: "Edit", url: view.edit_admin_order_path(resource) },
      { label: "Invoice", url: view.invoice_admin_order_path(resource) },
    ]
  end
end
```

The `view` parameter provides access to route helpers. Each action hash supports:

| Key | Required | Description |
|-----|----------|-------------|
| `label` | Yes | Button text |
| `url` | Yes | Link URL |
| `method` | No | HTTP method (e.g. `"delete"` or `:delete`; normalized case-insensitively) — renders as a form instead of a link |
| `confirm` | No | Confirmation message shown before executing (only used with `method: "delete"`) |
| `sg_visit` | No | Set to `false` to bypass SPA navigation and perform a standard browser request (useful for actions that redirect outside the admin) |

Custom actions also appear in has_many tables on show pages — for example, if a Customer has_many Orders, the orders table on the customer show page will use the OrderDashboard's custom actions.

To add a custom action endpoint, define the route and controller action:

```ruby
# config/routes.rb
resources :orders do
  member { get :invoice }
end

# app/controllers/admin/orders_controller.rb
def invoice
  redirect_to request.referer || admin_orders_path,
    notice: "Printing invoice"
end
```

Resources without a `collection_item_actions` override use the default Show/Edit/Destroy buttons.

## Custom Toolbar Actions

The index toolbar includes an `Export CSV` action by default. Add or replace toolbar buttons with `collection_toolbar_actions`:

```ruby
class OrderDashboard < Terrazzo::BaseDashboard
  # ...

  def collection_toolbar_actions(view)
    super + [
      { label: "Sync Orders", url: view.sync_admin_orders_path, method: "post" },
    ]
  end
end
```

Toolbar actions use the same action hash shape as row actions.

## Page Header Actions

Use `layout_actions` to add buttons to the page header slot on index, show, new, and edit pages:

```ruby
class OrderDashboard < Terrazzo::BaseDashboard
  # ...

  def layout_actions(page, view, resource: nil)
    return [] unless page == :show && resource

    [
      {
        label: "Print Invoice",
        url: view.invoice_admin_order_path(resource),
        variant: "default",
        sg_visit: false,
      },
    ]
  end
end
```

Layout actions use the same action hash shape as row and toolbar actions. Use this for page-level actions before ejecting the full layout or page.

## CSV Exports

The default CSV export uses the filtered, searched, and sorted index relation, exports all matching rows, and uses `COLLECTION_ATTRIBUTES` as columns.

Customize the export with dashboard methods:

```ruby
class OrderDashboard < Terrazzo::BaseDashboard
  # ...

  def csv_attributes
    %i[id customer created_at total]
  end

  def csv_filename
    "orders-export.csv"
  end

  def csv_value(attribute, value, resource)
    return resource.total_cents / 100.0 if attribute == :total

    super
  end
end
```

Disable CSV export with:

```ruby
def csv_export_enabled?
  false
end
```

## Empty State

Override `empty_collection_message` to customize the message shown when the index table has no rows:

```ruby
def empty_collection_message
  "No orders match your search or filters."
end
```

## Sidebar Navigation

Dashboards can control how their resource appears in the sidebar without ejecting the navigation partial:

```ruby
class OrderDashboard < Terrazzo::BaseDashboard
  NAVIGATION_LABEL = "Orders"
  NAVIGATION_GROUP = "Commerce"
  NAVIGATION_GROUP_ORDER = 10
  NAVIGATION_ORDER = 20
end
```

Use `SHOW_IN_NAVIGATION = false` to hide a resource from the generated sidebar.

Resources for namespaced models are grouped by namespace by default, so `Blog::PostDashboard` appears under `Blog`. Non-namespaced resources appear under `Resources`.

## Generating Dashboards

```bash
rails g terrazzo:dashboard Product
```

The generator inspects your model's columns and associations to produce a reasonable starting dashboard. You can then customize it as needed.

## All Instance Methods

| Method | Description |
|--------|-------------|
| `#attribute_types` | Returns the `ATTRIBUTE_TYPES` hash |
| `#attribute_type_for(attr)` | Returns the field class for a given attribute |
| `#form_attributes(action)` | Returns form attributes — `nil` returns `FORM_ATTRIBUTES`, `"create"` returns `FORM_ATTRIBUTES_NEW` if defined, `"update"` returns `FORM_ATTRIBUTES_EDIT` if defined |
| `#collection_attributes` | Returns `COLLECTION_ATTRIBUTES` |
| `#show_page_attributes` | Returns `SHOW_PAGE_ATTRIBUTES` |
| `#search_attributes` | Returns attributes where `.searchable?` is `true` |
| `#collection_includes` | Returns eager-loadable attributes visible in collection |
| `#permitted_attributes` | Maps form attributes through `.permitted_attribute` for strong params |
| `#display_resource(resource)` | Display string for the resource (default: `"ClassName #id"`) |
| `#attribute_label(attribute, context)` | Display label for an attribute on index, show, form, nested table, and CSV contexts |
| `#attribute_hint(attribute, context)` | Supporting text for attributes on form and show contexts |
| `#collection_cell_options(attribute, resource)` | Per-cell metadata for index and nested `has_many` tables |
| `#collection_filter_options(view)` | Index filter facets generated from `COLLECTION_FILTERS` |
| `#collection_filter_label(filter_name)` | Label for an index filter facet |
| `#collection_item_actions(resource, view)` | Per-row action buttons (default: Show/Edit/Destroy) |
| `#collection_toolbar_actions(view)` | Index toolbar actions (default: Export CSV) |
| `#layout_actions(page, view, resource:)` | Page header action slot for index, show, new, and edit pages |
| `#csv_export_enabled?` | Whether to show the default CSV export action |
| `#csv_attributes` | Attributes exported to CSV (default: `COLLECTION_ATTRIBUTES`) |
| `#csv_filename` | Download filename for CSV exports |
| `#csv_value(attribute, value, resource)` | Converts a serialized field value for CSV output |
| `#empty_collection_message` | Index empty-state description |
| `#navigation_label` | Sidebar link label (default: plural resource name) |
| `#navigation_group` | Sidebar group label (default: model namespace or `Resources`) |
| `#navigation_group_order` | Sort key for sidebar groups |
| `#navigation_order` | Sort key within a sidebar group |
| `#show_in_navigation?` | Whether the resource appears in the generated sidebar |
