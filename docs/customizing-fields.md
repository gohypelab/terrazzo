# Customizing Fields

Terrazzo ships with 17 field types. Each field knows how to serialize itself for JSON and has three display modes: **index** (table cell), **show** (detail view), and **form** (input).

## Setting Options

Use `.with_options` to configure any field:

```ruby
ATTRIBUTE_TYPES = {
  name: Field::String.with_options(truncate: 30),
  price: Field::Number.with_options(prefix: "$", decimals: 2),
  status: Field::Select.with_options(collection: -> { MyModel.statuses.keys }),
  author: Field::BelongsTo.with_options(scope: -> { User.where(role: :author) }),
}
```

## Field Types

### **Field::String**

```ruby
name: Field::String
```

- **Index**: Truncated to 50 characters (configurable with `truncate` option)
- **Show**: Full text
- **Form**: Text input

Options: `truncate` (default: 50)

### **Field::Text**

```ruby
description: Field::Text
```

- **Index**: Truncated
- **Show**: Full text
- **Form**: Textarea

### **Field::Number**

```ruby
price: Field::Number.with_options(prefix: "$", decimals: 2)
```

Options: `prefix`, `suffix`, `decimals`, `multiplier`, `format`

The `format` option uses `ActiveSupport::NumberHelper` for advanced formatting:

```ruby
price: Field::Number.with_options(
  format: { formatter: :number_to_currency, formatter_options: { unit: "€" } }
)
percentage: Field::Number.with_options(
  format: { formatter: :number_to_percentage, formatter_options: { precision: 1 } }
)
```

### **Field::Money**

```ruby
price: Field::Money
amount: Field::Money.with_options(prefix: "€", decimals: 2)
```

Like `Number` but defaults to 2 decimal places. Options: `prefix`, `suffix`, `decimals`

### **Field::Boolean**

```ruby
active: Field::Boolean
```

- **Index/Show**: Check or X badge
- **Form**: Checkbox

### **Field::Date** / **Field::DateTime** / **Field::Time**

```ruby
published_on: Field::Date
created_at: Field::DateTime
starts_at: Field::Time
```

Options:
- `format` — Ruby `strftime` format string (e.g., `"%b %d, %Y"`). When set, the value is formatted server-side.
- `timezone` — Timezone name (e.g., `"Eastern Time (US & Canada)"`) to convert the value before formatting. Defaults to `Time.zone`.

### **Field::Email**

```ruby
email: Field::Email
```

Renders as a clickable `mailto:` link on index and show pages.

### **Field::Url**

```ruby
website: Field::Url
```

Renders as an external link on index and show pages.

### **Field::Password**

```ruby
password: Field::Password
```

Renders as `••••••••` on index and show pages. Password input on forms.

### **Field::Select**

```ruby
status: Field::Select.with_options(
  collection: %w[draft published archived]
)
```

Options: `collection` — array, proc, or ActiveRecord enum name.

### **Field::RichText**

```ruby
body: Field::RichText
```

For Action Text fields. Renders HTML on show, textarea on form.

### **Field::BelongsTo**

```ruby
customer: Field::BelongsTo
```

- **Index/Show**: Link to the associated record
- **Form**: Select dropdown with all available records

Options: `scope` (proc to filter records), `include_blank`, `order` (e.g., `order: :name` to sort dropdown options)

### **Field::HasMany**

```ruby
orders: Field::HasMany
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
profile: Field::HasOne
```

- **Index/Show**: Link to the associated record
- **Form**: Read-only

Options: `scope`

### **Field::Polymorphic**

```ruby
commentable: Field::Polymorphic.with_options(
  classes: ["Post", "Comment"]
)
```

- **Form**: Grouped select (by type, then by record)

Options:
- `classes` — array of model class names this association can point to
- `order` — sort candidate resources per class (e.g., `order: :name`)

### **Field::Hstore**

```ruby
metadata: Field::Hstore
settings: Field::Hstore.with_options(truncate: 50)
```

Renders PostgreSQL `hstore` columns as interactive key-value pair editors. Index shows a truncated preview, show displays each key-value pair with badges, and the form provides an add/remove row editor.

Options: `truncate` (default: 80)

### **Field::Asset**

```ruby
avatar: Field::Asset
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

## Creating a Custom Field

Use the field generator to scaffold a custom field type:

```bash
rails g terrazzo:field Gravatar
```

This creates:

- `app/fields/gravatar_field.rb` — Ruby field class
- `app/views/admin/fields/gravatar/IndexField.jsx` — table cell component
- `app/views/admin/fields/gravatar/ShowField.jsx` — detail view component
- `app/views/admin/fields/gravatar/FormField.jsx` — form input component

It also registers the components in `app/views/admin/fields/index.js` so the field renderer can find them.

### The Ruby class

The generated class inherits from `Field::Base`. Override `serialize_value(mode)` to control what data is sent to the frontend for each mode (`:index`, `:show`, `:form`):

```ruby
module Terrazzo
  module Field
    class Gravatar < Base
      def serialize_value(mode)
        return nil if data.blank?

        email = data.downcase.strip
        hash = Digest::MD5.hexdigest(email)
        case mode
        when :index
          { url: "https://gravatar.com/avatar/#{hash}?s=32", email: email }
        when :show
          { url: "https://gravatar.com/avatar/#{hash}?s=128", email: email }
        when :form
          email
        end
      end

      class << self
        def searchable?
          false
        end

        def sortable?
          false
        end
      end
    end
  end
end
```

Use `serializable_options` to pass field configuration to the frontend:

```ruby
def serializable_options
  { size: options.fetch(:size, 128) }
end
```

### The JSX components

Each component receives the serialized value and options as props. For example, `ShowField.jsx`:

```jsx
import React from "react";

export function ShowField({ value, options }) {
  if (!value) return null;
  return (
    <img
      src={value.url}
      alt={value.email}
      className="rounded-full"
      width={options.size || 128}
    />
  );
}
```

### Using the field

Reference it in your dashboard like any built-in field:

```ruby
ATTRIBUTE_TYPES = {
  email: Field::Gravatar,
  # or with options:
  email: Field::Gravatar.with_options(size: 64),
}
```

## Base Field API

All field types inherit from `Field::Base`.

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
