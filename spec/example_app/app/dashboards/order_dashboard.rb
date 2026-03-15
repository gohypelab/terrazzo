require "super_admin/base_dashboard"

class OrderDashboard < SuperAdmin::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: SuperAdmin::Field::Number,
    customer: SuperAdmin::Field::BelongsTo,
    address_line_one: SuperAdmin::Field::String,
    address_line_two: SuperAdmin::Field::String,
    address_city: SuperAdmin::Field::String,
    address_state: SuperAdmin::Field::String,
    address_zip: SuperAdmin::Field::String,
    shipped_at: SuperAdmin::Field::DateTime,
    line_items: SuperAdmin::Field::HasMany,
    payments: SuperAdmin::Field::HasMany,
    log_entries: SuperAdmin::Field::HasMany,
    created_at: SuperAdmin::Field::DateTime,
    updated_at: SuperAdmin::Field::DateTime,
  }.freeze

  COLLECTION_ATTRIBUTES = %i[id customer address_city shipped_at].freeze
  SHOW_PAGE_ATTRIBUTES = %i[id customer address_line_one address_line_two address_city address_state address_zip shipped_at line_items payments log_entries created_at updated_at].freeze
  FORM_ATTRIBUTES = %i[customer address_line_one address_line_two address_city address_state address_zip shipped_at line_items payments log_entries].freeze
end
