# Field Types Reference

All field types inherit from `SuperAdmin::Field::Base`.

## Base Field API

| Method | Description |
|--------|-------------|
| `#field_type` | Returns the underscored type name (e.g., `"string"`, `"belongs_to"`) |
| `#serialize_value(mode)` | Returns the serialized value for `:index`, `:show`, or `:form` mode |
| `#serializable_options` | Returns a hash of options sent to the React component |
| `#required?` | `true` if the model has a presence validator on this attribute |
| `.searchable?` | Whether this field type supports search (default: `false`) |
| `.sortable?` | Whether this field type supports sorting (default: `true`) |
| `.eager_load?` | Whether to eager-load this association (default: `false`) |
| `.with_options(opts)` | Returns a deferred field with merged options |
| `.permitted_attribute` | Returns the attribute name for strong parameters |

## Field Types

| Type | Class | Searchable | Sortable | Eager Load |
|------|-------|-----------|----------|------------|
| String | `Field::String` | Yes | Yes | No |
| Text | `Field::Text` | Yes | Yes | No |
| Number | `Field::Number` | No | Yes | No |
| Boolean | `Field::Boolean` | No | Yes | No |
| Date | `Field::Date` | No | Yes | No |
| DateTime | `Field::DateTime` | No | Yes | No |
| Time | `Field::Time` | No | Yes | No |
| Email | `Field::Email` | Yes | Yes | No |
| URL | `Field::Url` | No | Yes | No |
| Password | `Field::Password` | No | No | No |
| Select | `Field::Select` | No | Yes | No |
| Rich Text | `Field::RichText` | Yes | No | No |
| BelongsTo | `Field::BelongsTo` | No | Yes | Yes |
| HasMany | `Field::HasMany` | No | Yes | No |
| HasOne | `Field::HasOne` | No | No | Yes |
| Polymorphic | `Field::Polymorphic` | No | No | No |
| Hstore | `Field::Hstore` | No | No | No |

## Options by Field Type

### String
- `truncate` — max characters on index (default: 50)

### Number
- `prefix` — string prepended to display (e.g., `"$"`)
- `suffix` — string appended to display
- `decimals` — number of decimal places

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

### HasMany / HasOne
- `scope` — proc to filter available records
