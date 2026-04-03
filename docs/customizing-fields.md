# Customizing Fields

Terrazzo ships with 17 field types. Each field knows how to serialize itself for JSON and has three display modes: **index** (table cell), **show** (detail view), and **form** (input).

## Setting Options

Use `.with_options` to configure any field:

```ruby
ATTRIBUTE_TYPES = {
  name: Terrazzo::Field::String.with_options(truncate: 30),
  price: Terrazzo::Field::Number.with_options(prefix: "$", decimals: 2),
  status: Terrazzo::Field::Select.with_options(collection: -> { MyModel.statuses.keys }),
  author: Terrazzo::Field::BelongsTo.with_options(scope: -> { User.where(role: :author) }),
}
```

## Field Types

### **Field::String**

```ruby
name: Terrazzo::Field::String
```

- **Index**: Truncated to 50 characters (configurable with `truncate` option)
- **Show**: Full text
- **Form**: Text input

Options: `truncate` (default: 50)

### **Field::Text**

```ruby
description: Terrazzo::Field::Text
```

- **Index**: Truncated
- **Show**: Full text
- **Form**: Textarea

### **Field::Number**

```ruby
price: Terrazzo::Field::Number.with_options(prefix: "$", decimals: 2)
```

Options: `prefix`, `suffix`, `decimals`, `multiplier`, `format`

The `format` option uses `ActiveSupport::NumberHelper` for advanced formatting:

```ruby
price: Terrazzo::Field::Number.with_options(
  format: { formatter: :number_to_currency, formatter_options: { unit: "€" } }
)
percentage: Terrazzo::Field::Number.with_options(
  format: { formatter: :number_to_percentage, formatter_options: { precision: 1 } }
)
```

### **Field::Money**

```ruby
price: Terrazzo::Field::Money
amount: Terrazzo::Field::Money.with_options(prefix: "€", decimals: 2)
```

Like `Number` but defaults to 2 decimal places. Options: `prefix`, `suffix`, `decimals`

### **Field::Boolean**

```ruby
active: Terrazzo::Field::Boolean
```

- **Index/Show**: Check or X badge
- **Form**: Checkbox

### **Field::Date** / **Field::DateTime** / **Field::Time**

```ruby
published_on: Terrazzo::Field::Date
created_at: Terrazzo::Field::DateTime
starts_at: Terrazzo::Field::Time
```

Options:
- `format` — Ruby `strftime` format string (e.g., `"%b %d, %Y"`). When set, the value is formatted server-side.
- `timezone` — Timezone name (e.g., `"Eastern Time (US & Canada)"`) to convert the value before formatting. Defaults to `Time.zone`.

### **Field::Email**

```ruby
email: Terrazzo::Field::Email
```

Renders as a clickable `mailto:` link on index and show pages.

### **Field::Url**

```ruby
website: Terrazzo::Field::Url
```

Renders as an external link on index and show pages.

### **Field::Password**

```ruby
password: Terrazzo::Field::Password
```

Renders as `••••••••` on index and show pages. Password input on forms.

### **Field::Select**

```ruby
status: Terrazzo::Field::Select.with_options(
  collection: %w[draft published archived]
)
```

Options: `collection` — array, proc, or ActiveRecord enum name.

### **Field::RichText**

```ruby
body: Terrazzo::Field::RichText
```

For Action Text fields. Renders HTML on show, textarea on form.

### **Field::BelongsTo**

```ruby
customer: Terrazzo::Field::BelongsTo
```

- **Index/Show**: Link to the associated record
- **Form**: Select dropdown with all available records

Options: `scope` (proc to filter records), `include_blank`, `order` (e.g., `order: :name` to sort dropdown options)

### **Field::HasMany**

```ruby
orders: Terrazzo::Field::HasMany
```

- **Index**: Count badge
- **Show**: Table with collection attributes and per-row actions
- **Form**: Multi-select

Options:
- `collection_attributes` — array of attributes to show in the has_many table on the show page. Defaults to the associated dashboard's `COLLECTION_ATTRIBUTES`. Use this to show fewer or different columns:
  ```ruby
  orders: Field::HasMany.with_options(
    collection_attributes: [:id, :address_city, :created_at]
  )
  ```
- `scope` — proc to filter records
- `sort_by` — attribute to sort related items on show page (e.g., `sort_by: :created_at`)
- `direction` — sort direction, `:asc` (default) or `:desc`
- `includes` — eager-load nested associations (e.g., `includes: [:author]`)

### **Field::HasOne**

```ruby
profile: Terrazzo::Field::HasOne
```

- **Index/Show**: Link to the associated record
- **Form**: Read-only

Options: `scope`

### **Field::Polymorphic**

```ruby
commentable: Terrazzo::Field::Polymorphic.with_options(
  classes: ["Post", "Comment"]
)
```

- **Form**: Grouped select (by type, then by record)

Options:
- `classes` — array of model class names this association can point to
- `order` — sort candidate resources per class (e.g., `order: :name`)

### **Field::Hstore**

```ruby
metadata: Terrazzo::Field::Hstore
settings: Terrazzo::Field::Hstore.with_options(truncate: 50)
```

Renders PostgreSQL `hstore` columns as interactive key-value pair editors. Index shows a truncated preview, show displays each key-value pair with badges, and the form provides an add/remove row editor.

Options: `truncate` (default: 80)

### **Field::Asset**

```ruby
avatar: Terrazzo::Field::Asset
```

For Active Storage `has_one_attached` fields. Shows the filename on index and show pages, file input on forms. The dashboard generator auto-detects `has_one_attached` declarations.

## Enabling Search

All field types default to `searchable: false`. Enable search on specific fields using `.with_options(searchable: true)`:

```ruby
ATTRIBUTE_TYPES = {
  name:  Field::String.with_options(searchable: true),
  email: Field::Email.with_options(searchable: true),
  owner: Field::BelongsTo.with_options(searchable: true, searchable_fields: ["name"]),
}
```

> **Note:** Unlike Administrate, Terrazzo does not auto-enable search on String/Text/Email fields. This avoids accidentally exposing sensitive data in search queries. Always opt in explicitly.

## Field Capabilities

| Type | Class | Searchable | Sortable | Eager Load |
|------|-------|-----------|----------|------------|
| String | `Field::String` | No | Yes | No |
| Text | `Field::Text` | No | Yes | No |
| Number | `Field::Number` | No | Yes | No |
| Money | `Field::Money` | No | Yes | No |
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
| Hstore | `Field::Hstore` | No | No | No |
| Asset | `Field::Asset` | No | No | Yes |

## Base Field API

All field types inherit from `Terrazzo::Field::Base`.

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
