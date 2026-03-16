require "terrazzo/base_dashboard"

class PaymentDashboard < Terrazzo::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Terrazzo::Field::Number,
    created_at: Terrazzo::Field::DateTime,
    updated_at: Terrazzo::Field::DateTime,
    order: Terrazzo::Field::BelongsTo,
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
