require "super_admin/base_dashboard"

class CustomerDashboard < SuperAdmin::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: SuperAdmin::Field::Number,
    name: SuperAdmin::Field::String,
    email: SuperAdmin::Field::Email,
    created_at: SuperAdmin::Field::DateTime,
    updated_at: SuperAdmin::Field::DateTime,
    email_subscriber: SuperAdmin::Field::Boolean,
    kind: SuperAdmin::Field::Select.with_options(collection: ["standard", "vip"]),
    example_time: SuperAdmin::Field::Time,
    password: SuperAdmin::Field::Password,
    hidden: SuperAdmin::Field::Boolean,
    orders: SuperAdmin::Field::HasMany,
    territory: SuperAdmin::Field::BelongsTo,
    log_entries: SuperAdmin::Field::HasMany,
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
