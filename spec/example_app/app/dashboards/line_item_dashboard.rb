require "super_admin/base_dashboard"

class LineItemDashboard < SuperAdmin::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: SuperAdmin::Field::Number,
    order: SuperAdmin::Field::BelongsTo,
    product: SuperAdmin::Field::BelongsTo,
    unit_price: SuperAdmin::Field::Number.with_options(prefix: "$", decimals: 2),
    quantity: SuperAdmin::Field::Number,
    created_at: SuperAdmin::Field::DateTime,
    updated_at: SuperAdmin::Field::DateTime,
  }.freeze

  COLLECTION_ATTRIBUTES = %i[id order product unit_price].freeze
  SHOW_PAGE_ATTRIBUTES = %i[id order product unit_price quantity created_at updated_at].freeze
  FORM_ATTRIBUTES = %i[order product unit_price quantity].freeze
end
