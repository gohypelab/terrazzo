require "super_admin/base_dashboard"

class CustomerDashboard < SuperAdmin::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: SuperAdmin::Field::Number,
    name: SuperAdmin::Field::String,
    email: SuperAdmin::Field::Email,
    email_subscriber: SuperAdmin::Field::Boolean,
    kind: SuperAdmin::Field::Select.with_options(collection: %w[standard vip]),
    password: SuperAdmin::Field::Password,
    orders: SuperAdmin::Field::HasMany,
    territory: SuperAdmin::Field::BelongsTo,
    log_entries: SuperAdmin::Field::HasMany,
    created_at: SuperAdmin::Field::DateTime,
    updated_at: SuperAdmin::Field::DateTime,
  }.freeze

  COLLECTION_ATTRIBUTES = %i[id name email kind].freeze
  SHOW_PAGE_ATTRIBUTES = %i[id name email email_subscriber kind password orders territory log_entries created_at updated_at].freeze
  FORM_ATTRIBUTES = %i[name email email_subscriber kind password territory].freeze
end
