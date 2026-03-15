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

Returns only attributes where the field type's `.searchable?` returns `true`.

### `#collection_includes`

Returns attributes where the field type's `.eager_load?` returns `true`. Used for eager-loading associations on the index page.

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
