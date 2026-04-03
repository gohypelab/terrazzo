# Dashboard DSL Reference

## Class Methods

### `.model`

Returns the model class derived from the dashboard name.

```ruby
CustomerDashboard.model # => Customer
Blog::PostDashboard.model # => Blog::Post
```

### `.resource_name`

Returns the model's human-readable name.

## Instance Methods

### `#attribute_types`

Returns the `ATTRIBUTE_TYPES` hash.

### `#attribute_type_for(attr)`

Returns the field class for a given attribute. Raises an error if the attribute is not defined.

### `#form_attributes(action = nil)`

Returns form attributes for the given action:
- `form_attributes` or `form_attributes(nil)` — returns `FORM_ATTRIBUTES`
- `form_attributes("create")` — returns `FORM_ATTRIBUTES_NEW` if defined, else `FORM_ATTRIBUTES`
- `form_attributes("update")` — returns `FORM_ATTRIBUTES_EDIT` if defined, else `FORM_ATTRIBUTES`

### `#collection_attributes`

Returns `COLLECTION_ATTRIBUTES`. Supports both array and hash formats (hash values are flattened).

### `#show_page_attributes`

Returns `SHOW_PAGE_ATTRIBUTES`.

### `#search_attributes`

Returns only attributes (from `ATTRIBUTE_TYPES`) where the field type's `.searchable?` returns `true`. No field types are searchable by default — opt in with `.with_options(searchable: true)`.

### `#collection_includes`

Returns attributes that appear in `COLLECTION_ATTRIBUTES` **and** whose field type's `.eager_load?` returns `true`. Used for eager-loading associations on the index page. Only associations visible in the collection view are included, avoiding unnecessary JOINs.

### `#permitted_attributes`

Maps each form attribute through its field type's `.permitted_attribute` method. Used for strong parameters.

### `#display_resource(resource)`

Returns a display string for the resource. Default: `"ClassName #id"`.

Override this to show something more meaningful:

```ruby
def display_resource(resource)
  resource.name
end
```

### `#collection_item_actions(resource, view)`

Returns an array of action hashes for each row on the index page and in has_many tables on show pages. Override this to customize the per-row action buttons for a specific resource type.

Each action hash supports:

| Key | Required | Description |
|-----|----------|-------------|
| `label` | Yes | Button text |
| `url` | Yes | Link URL |
| `method` | No | HTTP method (e.g. `"delete"`) — renders as a form instead of a link |
| `confirm` | No | Confirmation message shown before executing (only used with `method: "delete"`) |

**Default behavior** (when not overridden): renders Show, Edit, and Destroy buttons using polymorphic routes.

```ruby
def collection_item_actions(resource, view)
  [
    { label: "View", url: view.admin_order_path(resource) },
    { label: "Edit", url: view.edit_admin_order_path(resource) },
    { label: "Invoice", url: view.invoice_admin_order_path(resource) },
  ]
end
```

The `view` parameter is the view context, giving access to route helpers and other view methods.

## Constants

| Constant | Required | Description |
|----------|----------|-------------|
| `ATTRIBUTE_TYPES` | Yes | Hash of attribute name → field type |
| `COLLECTION_ATTRIBUTES` | Yes | Attributes shown on index page |
| `SHOW_PAGE_ATTRIBUTES` | Yes | Attributes shown on show page |
| `FORM_ATTRIBUTES` | Yes | Attributes shown on forms |
| `FORM_ATTRIBUTES_NEW` | No | Override form attributes for create |
| `FORM_ATTRIBUTES_EDIT` | No | Override form attributes for update |
| `COLLECTION_FILTERS` | No | Named filters for the index page |
