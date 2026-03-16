require "super_admin/base_dashboard"

class PaymentDashboard < SuperAdmin::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: SuperAdmin::Field::Number,
    created_at: SuperAdmin::Field::DateTime,
    updated_at: SuperAdmin::Field::DateTime,
    order: SuperAdmin::Field::BelongsTo,
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    id
    order
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    id
    created_at
    updated_at
    order
  ].freeze

  FORM_ATTRIBUTES = %i[
    order
  ].freeze

  # COLLECTION_FILTERS = {
  #   active: ->(resources) { resources.where(active: true) },
  #   recent: ->(resources) { resources.where("created_at > ?", 30.days.ago) },
  # }.freeze
end
