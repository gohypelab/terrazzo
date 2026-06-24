require "terrazzo/base_dashboard"

class LineItemDashboard < Terrazzo::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::String,
    unit_price: Field::Number,
    quantity: Field::Number,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    order: Field::BelongsTo,
    product: Field::BelongsTo,
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

  # Overwrite this method to customize how line items are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(resource)
  #   "LineItem ##{resource.id}"
  # end
end
