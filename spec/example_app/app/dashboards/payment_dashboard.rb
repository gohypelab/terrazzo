require "super_admin/base_dashboard"

class PaymentDashboard < SuperAdmin::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: SuperAdmin::Field::Number,
    order: SuperAdmin::Field::BelongsTo,
    created_at: SuperAdmin::Field::DateTime,
    updated_at: SuperAdmin::Field::DateTime,
  }.freeze

  COLLECTION_ATTRIBUTES = %i[id order created_at].freeze
  SHOW_PAGE_ATTRIBUTES = %i[id order created_at updated_at].freeze
  FORM_ATTRIBUTES = %i[order].freeze
end
