require "super_admin/base_dashboard"

class LineItemDashboard < SuperAdmin::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: SuperAdmin::Field::Number,
    unit_price: SuperAdmin::Field::Number.with_options(prefix: "$", decimals: 2),
    quantity: SuperAdmin::Field::Number,
    created_at: SuperAdmin::Field::DateTime,
    updated_at: SuperAdmin::Field::DateTime,
    order: SuperAdmin::Field::BelongsTo,
    product: SuperAdmin::Field::BelongsTo,
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
