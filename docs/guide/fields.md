# Fields

SuperAdmin ships with 16 field types. Each field knows how to serialize itself for JSON and has three display modes: **index** (table cell), **show** (detail view), and **form** (input).

## Basic Fields

### String

```ruby
name: SuperAdmin::Field::String
```

- **Index**: Truncated to 50 characters (configurable with `truncate` option)
- **Show**: Full text
- **Form**: Text input
- **Searchable**: Yes

### Text

```ruby
description: SuperAdmin::Field::Text
```

- **Index**: Truncated
- **Show**: Full text
- **Form**: Textarea

### Number

```ruby
price: SuperAdmin::Field::Number.with_options(prefix: "$", decimals: 2)
```

Options: `prefix`, `suffix`, `decimals`

### Boolean

```ruby
active: SuperAdmin::Field::Boolean
```

- **Index/Show**: Check or X badge
- **Form**: Checkbox

### Date / DateTime / Time

```ruby
published_on: SuperAdmin::Field::Date
created_at: SuperAdmin::Field::DateTime
starts_at: SuperAdmin::Field::Time
```

### Email

```ruby
email: SuperAdmin::Field::Email
```

Renders as a clickable `mailto:` link on index and show pages.

### URL

```ruby
website: SuperAdmin::Field::Url
```

Renders as an external link on index and show pages.

### Password

```ruby
password: SuperAdmin::Field::Password
```

Renders as `••••••••` on index and show pages. Password input on forms.

### Select

```ruby
status: SuperAdmin::Field::Select.with_options(
  collection: %w[draft published archived]
)
```

The `collection` option accepts an array, a proc, or an ActiveRecord enum name.

### Rich Text

```ruby
body: SuperAdmin::Field::RichText
```

For Action Text fields. Renders HTML on show, textarea on form.

## Association Fields

### BelongsTo

```ruby
customer: SuperAdmin::Field::BelongsTo
```

- **Index/Show**: Link to the associated record
- **Form**: Select dropdown with all available records

Options: `scope`, `include_blank`

### HasMany

```ruby
orders: SuperAdmin::Field::HasMany
```

- **Index**: Count badge
- **Show**: List of links
- **Form**: Multi-select

### HasOne

```ruby
profile: SuperAdmin::Field::HasOne
```

- **Index/Show**: Link to the associated record
- **Form**: Read-only

### Polymorphic

```ruby
commentable: SuperAdmin::Field::Polymorphic
```

- **Form**: Grouped select (by type, then by record)

## Field Options

Use `.with_options` to configure any field:

```ruby
ATTRIBUTE_TYPES = {
  name: SuperAdmin::Field::String.with_options(truncate: 30),
  price: SuperAdmin::Field::Number.with_options(prefix: "$", decimals: 2),
  status: SuperAdmin::Field::Select.with_options(collection: -> { MyModel.statuses.keys }),
  author: SuperAdmin::Field::BelongsTo.with_options(scope: -> { User.where(role: :author) }),
}
```
