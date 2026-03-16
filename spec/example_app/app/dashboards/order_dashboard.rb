require "terrazzo/base_dashboard"

class OrderDashboard < Terrazzo::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Terrazzo::Field::Number,
    address_line_one: Terrazzo::Field::String,
    address_line_two: Terrazzo::Field::String,
    address_city: Terrazzo::Field::String,
    address_state: Terrazzo::Field::String,
    address_zip: Terrazzo::Field::String,
    created_at: Terrazzo::Field::DateTime,
    updated_at: Terrazzo::Field::DateTime,
    shipped_at: Terrazzo::Field::DateTime,
    customer: Terrazzo::Field::BelongsTo,
    line_items: Terrazzo::Field::HasMany,
    payments: Terrazzo::Field::HasMany,
    log_entries: Terrazzo::Field::HasMany,
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    id
    customer
    address_city
    shipped_at
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    id
    address_line_one
    address_line_two
    address_city
    address_state
    address_zip
    created_at
    updated_at
    shipped_at
    customer
    line_items
    payments
    log_entries
  ].freeze

  FORM_ATTRIBUTES = %i[
    address_line_one
    address_line_two
    address_city
    address_state
    address_zip
    shipped_at
    customer
    line_items
    payments
    log_entries
  ].freeze

  # COLLECTION_FILTERS = {
  #   active: ->(resources) { resources.where(active: true) },
  #   recent: ->(resources) { resources.where("created_at > ?", 30.days.ago) },
  # }.freeze
end
