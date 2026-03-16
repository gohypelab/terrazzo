require "super_admin/base_dashboard"

class OrderDashboard < SuperAdmin::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: SuperAdmin::Field::Number,
    address_line_one: SuperAdmin::Field::String,
    address_line_two: SuperAdmin::Field::String,
    address_city: SuperAdmin::Field::String,
    address_state: SuperAdmin::Field::String,
    address_zip: SuperAdmin::Field::String,
    created_at: SuperAdmin::Field::DateTime,
    updated_at: SuperAdmin::Field::DateTime,
    shipped_at: SuperAdmin::Field::DateTime,
    customer: SuperAdmin::Field::BelongsTo,
    line_items: SuperAdmin::Field::HasMany,
    payments: SuperAdmin::Field::HasMany,
    log_entries: SuperAdmin::Field::HasMany,
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
