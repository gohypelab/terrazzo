require "terrazzo/base_dashboard"

class CustomerDashboard < Terrazzo::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Terrazzo::Field::Number,
    name: Terrazzo::Field::String,
    email: Terrazzo::Field::Email,
    created_at: Terrazzo::Field::DateTime,
    updated_at: Terrazzo::Field::DateTime,
    email_subscriber: Terrazzo::Field::Boolean,
    kind: Terrazzo::Field::Select.with_options(collection: ["standard", "vip"]),
    example_time: Terrazzo::Field::Time,
    password: Terrazzo::Field::Password,
    hidden: Terrazzo::Field::Boolean,
    orders: Terrazzo::Field::HasMany,
    territory: Terrazzo::Field::BelongsTo,
    log_entries: Terrazzo::Field::HasMany,
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    id
    name
    email
    kind
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    id
    name
    email
    created_at
    updated_at
    email_subscriber
    kind
    example_time
    password
    hidden
    orders
    territory
    log_entries
  ].freeze

  FORM_ATTRIBUTES = %i[
    name
    email
    email_subscriber
    kind
    example_time
    password
    hidden
    orders
    territory
    log_entries
  ].freeze

  # COLLECTION_FILTERS = {
  #   active: ->(resources) { resources.where(active: true) },
  #   recent: ->(resources) { resources.where("created_at > ?", 30.days.ago) },
  # }.freeze
end
