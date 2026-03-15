require "super_admin/base_dashboard"

class LogEntryDashboard < SuperAdmin::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: SuperAdmin::Field::Number,
    action: SuperAdmin::Field::String,
    loggable: SuperAdmin::Field::Polymorphic.with_options(classes: ["Customer", "Order"]),
    created_at: SuperAdmin::Field::DateTime,
    updated_at: SuperAdmin::Field::DateTime,
  }.freeze

  COLLECTION_ATTRIBUTES = %i[id action loggable created_at].freeze
  SHOW_PAGE_ATTRIBUTES = %i[id action loggable created_at updated_at].freeze
  FORM_ATTRIBUTES = %i[action loggable].freeze
end
