# Field Types Reference

All field types inherit from `Terrazzo::Field::Base`.

## Base Field API

| Method | Description |
|--------|-------------|
| `#field_type` | Returns the underscored type name (e.g., `"string"`, `"belongs_to"`) |
| `#serialize_value(mode)` | Returns the serialized value for `:index`, `:show`, or `:form` mode |
| `#serializable_options` | Returns a hash of options sent to the React component |
| `#required?` | `true` if the model has a presence validator on this attribute |
| `.searchable?` | Whether this field type supports search (default: `false`). Opt in per-field with `.with_options(searchable: true)`. |
| `.sortable?` | Whether this field type supports sorting (default: `true`) |
| `.eager_load?` | Whether to eager-load this association (default: `false`) |
| `.with_options(opts)` | Returns a deferred field with merged options |
| `.permitted_attribute` | Returns the attribute name for strong parameters |

## Field Types

All field types default to `searchable: false`. Enable search on specific fields using `.with_options(searchable: true)` in your dashboard's `ATTRIBUTE_TYPES`.

> **Note:** Unlike Administrate, Terrazzo does not auto-enable search on String/Text/Email fields. This avoids accidentally exposing sensitive data in search queries. Always opt in explicitly.

| Type | Class | Searchable | Sortable | Eager Load |
|------|-------|-----------|----------|------------|
| String | `Field::String` | No | Yes | No |
| Text | `Field::Text` | No | Yes | No |
| Number | `Field::Number` | No | Yes | No |
| Boolean | `Field::Boolean` | No | Yes | No |
| Date | `Field::Date` | No | Yes | No |
| DateTime | `Field::DateTime` | No | Yes | No |
| Time | `Field::Time` | No | Yes | No |
| Email | `Field::Email` | No | Yes | No |
| URL | `Field::Url` | No | Yes | No |
| Password | `Field::Password` | No | No | No |
| Select | `Field::Select` | No | Yes | No |
| Rich Text | `Field::RichText` | No | No | No |
| BelongsTo | `Field::BelongsTo` | No | Yes | Yes |
| HasMany | `Field::HasMany` | No | Yes | No |
| HasOne | `Field::HasOne` | No | No | Yes |
| Polymorphic | `Field::Polymorphic` | No | No | No |
| Money | `Field::Money` | No | Yes | No |
| Hstore | `Field::Hstore` | No | No | No |
| Asset | `Field::Asset` | No | No | Yes |

### Enabling search

```ruby
ATTRIBUTE_TYPES = {
  name:  Field::String.with_options(searchable: true),
  email: Field::Email.with_options(searchable: true),
  owner: Field::BelongsTo.with_options(searchable: true, searchable_fields: ["name"]),
}
```

## Options by Field Type

### String
- `truncate` — max characters on index (default: 50)

### Number
- `prefix` — string prepended to display (e.g., `"$"`)
- `suffix` — string appended to display
- `decimals` — number of decimal places

### Money
- `prefix` — string prepended to display (e.g., `"$"`)
- `suffix` — string appended to display
- `decimals` — number of decimal places (default: 2)

Renders like `Field::Number` but defaults to 2 decimal places. The React component receives the numeric value along with the prefix/suffix/decimals options.

### Date / DateTime / Time
- `format` — Ruby `strftime` format string (e.g., `"%b %d, %Y"`). When set, the value is formatted on the server side. Without it, dates use the default serialization.

### Select
- `collection` — array, proc, or enum name

### BelongsTo
- `scope` — proc to filter available records
- `include_blank` — whether to allow blank selection

### Hstore
- `truncate` — max characters for the index preview (default: 80)

Renders PostgreSQL `hstore` columns as interactive key-value pair editors. On the index page, values appear as a truncated comma-separated preview. On the show page, each key-value pair is displayed with the key as a badge. The form provides an add/remove row editor for key-value pairs.

```ruby
ATTRIBUTE_TYPES = {
  metadata: Field::Hstore,
  settings: Field::Hstore.with_options(truncate: 50),
}
```

### Asset

For Active Storage `has_one_attached` fields. Shows the filename on index and show pages, and a file input on forms.

```ruby
ATTRIBUTE_TYPES = {
  avatar: Field::Asset,
}
```

The model must declare the attachment:

```ruby
class User < ApplicationRecord
  has_one_attached :avatar
end
```

The dashboard generator auto-detects `has_one_attached` declarations and maps them to `Field::Asset`.

### HasMany / HasOne
- `scope` — proc to filter available records
