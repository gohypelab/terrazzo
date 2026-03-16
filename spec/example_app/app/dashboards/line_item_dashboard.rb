require "terrazzo/base_dashboard"

class LineItemDashboard < Terrazzo::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Terrazzo::Field::Number,
    unit_price: Terrazzo::Field::Number.with_options(prefix: "$", decimals: 2),
    quantity: Terrazzo::Field::Number,
    created_at: Terrazzo::Field::DateTime,
    updated_at: Terrazzo::Field::DateTime,
    order: Terrazzo::Field::BelongsTo,
    product: Terrazzo::Field::BelongsTo,
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    id
    unit_price
    quantity
    order
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    id
    unit_price
    quantity
    created_at
    updated_at
    order
    product
  ].freeze

  FORM_ATTRIBUTES = %i[
    unit_price
    quantity
    order
    product
  ].freeze

  # COLLECTION_FILTERS = {
  #   active: ->(resources) { resources.where(active: true) },
  #   recent: ->(resources) { resources.where("created_at > ?", 30.days.ago) },
  # }.freeze
end
