# Fields

Terrazzo ships with 17 field types. Each field knows how to serialize itself for JSON and has three display modes: **index** (table cell), **show** (detail view), and **form** (input).

## Basic Fields

### String

```ruby
name: Terrazzo::Field::String
```

- **Index**: Truncated to 50 characters (configurable with `truncate` option)
- **Show**: Full text
- **Form**: Text input
- **Searchable**: Yes

### Text

```ruby
description: Terrazzo::Field::Text
```

- **Index**: Truncated
- **Show**: Full text
- **Form**: Textarea

### Number

```ruby
price: Terrazzo::Field::Number.with_options(prefix: "$", decimals: 2)
```

Options: `prefix`, `suffix`, `decimals`

### Money

```ruby
price: Terrazzo::Field::Money
amount: Terrazzo::Field::Money.with_options(prefix: "€", decimals: 2)
```

Like `Number` but defaults to 2 decimal places. Options: `prefix`, `suffix`, `decimals`

### Boolean

```ruby
active: Terrazzo::Field::Boolean
```

- **Index/Show**: Check or X badge
- **Form**: Checkbox

### Date / DateTime / Time

```ruby
published_on: Terrazzo::Field::Date
created_at: Terrazzo::Field::DateTime
starts_at: Terrazzo::Field::Time
```

### Email

```ruby
email: Terrazzo::Field::Email
```

Renders as a clickable `mailto:` link on index and show pages.

### URL

```ruby
website: Terrazzo::Field::Url
```

Renders as an external link on index and show pages.

### Password

```ruby
password: Terrazzo::Field::Password
```

Renders as `••••••••` on index and show pages. Password input on forms.

### Select

```ruby
status: Terrazzo::Field::Select.with_options(
  collection: %w[draft published archived]
)
```

The `collection` option accepts an array, a proc, or an ActiveRecord enum name.

### Rich Text

```ruby
body: Terrazzo::Field::RichText
```

For Action Text fields. Renders HTML on show, textarea on form.

## Association Fields

### BelongsTo

```ruby
customer: Terrazzo::Field::BelongsTo
```

- **Index/Show**: Link to the associated record
- **Form**: Select dropdown with all available records

Options: `scope`, `include_blank`

### HasMany

```ruby
orders: Terrazzo::Field::HasMany
```

- **Index**: Count badge
- **Show**: List of links
- **Form**: Multi-select

### HasOne

```ruby
profile: Terrazzo::Field::HasOne
```

- **Index/Show**: Link to the associated record
- **Form**: Read-only

### Polymorphic

```ruby
commentable: Terrazzo::Field::Polymorphic
```

- **Form**: Grouped select (by type, then by record)

## Field Options

Use `.with_options` to configure any field:

```ruby
ATTRIBUTE_TYPES = {
  name: Terrazzo::Field::String.with_options(truncate: 30),
  price: Terrazzo::Field::Number.with_options(prefix: "$", decimals: 2),
  status: Terrazzo::Field::Select.with_options(collection: -> { MyModel.statuses.keys }),
  author: Terrazzo::Field::BelongsTo.with_options(scope: -> { User.where(role: :author) }),
}
```
