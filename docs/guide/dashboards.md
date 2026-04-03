# Dashboards

Dashboards define which fields appear on each page of your admin panel. The DSL is identical to [Administrate](https://administrate-demo.herokuapp.com/).

## Basic Structure

```ruby
# app/dashboards/product_dashboard.rb
class ProductDashboard < Terrazzo::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Terrazzo::Field::Number,
    name: Terrazzo::Field::String,
    price: Terrazzo::Field::Number.with_options(prefix: "$", decimals: 2),
    description: Terrazzo::Field::Text,
    category: Terrazzo::Field::Select.with_options(
      collection: %w[Electronics Books Clothing]
    ),
    customer: Terrazzo::Field::BelongsTo,
    tags: Terrazzo::Field::HasMany,
    created_at: Terrazzo::Field::DateTime,
    updated_at: Terrazzo::Field::DateTime,
  }.freeze

  COLLECTION_ATTRIBUTES = %i[id name price category].freeze
  SHOW_PAGE_ATTRIBUTES = %i[id name price description category customer tags created_at updated_at].freeze
  FORM_ATTRIBUTES = %i[name price description category customer tags].freeze
end
```

## Constants

### `ATTRIBUTE_TYPES`

A hash mapping attribute names to field types. Every attribute you want to display anywhere must be listed here.

### `COLLECTION_ATTRIBUTES`

An array of attributes shown on the index (list) page. Keep this short — typically 3-5 columns.

### `SHOW_PAGE_ATTRIBUTES`

An array of attributes shown on the detail page.

### `FORM_ATTRIBUTES`

An array of attributes shown on the new/edit form. You can also define separate lists for create and update:

```ruby
FORM_ATTRIBUTES_NEW = %i[name email password].freeze
FORM_ATTRIBUTES_EDIT = %i[name email].freeze
```

When these are defined, they take precedence over `FORM_ATTRIBUTES` for their respective actions.

## Display Name

Override `display_resource` to customize how a record is shown in links and titles:

```ruby
def display_resource(resource)
  resource.name
end
```

The default is `"ClassName #id"`.

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

The `view` parameter provides access to route helpers. Custom actions also appear in has_many tables on show pages — for example, if a Customer has_many Orders, the orders table on the customer show page will use the OrderDashboard's custom actions.

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

## Generating Dashboards

```bash
rails g terrazzo:dashboard Product
```

The generator inspects your model's columns and associations to produce a reasonable starting dashboard. You can then customize it as needed.
