require "terrazzo/base_dashboard"

class CustomerDashboard < Terrazzo::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::String,
    name: Field::String,
    email: Field::Email,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    email_subscriber: Field::Boolean,
    kind: Field::Select.with_options(collection: ["standard", "vip"]),
    example_time: Field::Time,
    password: Field::Password,
    hidden: Field::Boolean,
    orders: Field::HasMany.with_options(collection_attributes: %i[id address_city]),
    territory: Field::BelongsTo,
    log_entries: Field::HasMany.with_options(render_actions: false),
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    id
    name
    email
    email_subscriber
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

  # Overwrite this method to customize how customers are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(resource)
  #   "Customer ##{resource.id}"
  # end
end
