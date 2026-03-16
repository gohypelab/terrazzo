require "terrazzo/base_dashboard"

class ProductMetaTagDashboard < Terrazzo::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Terrazzo::Field::Number,
    meta_title: Terrazzo::Field::String,
    meta_description: Terrazzo::Field::String,
    created_at: Terrazzo::Field::DateTime,
    updated_at: Terrazzo::Field::DateTime,
    product: Terrazzo::Field::BelongsTo,
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    id
    meta_title
    meta_description
    product
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    id
    meta_title
    meta_description
    created_at
    updated_at
    product
  ].freeze

  FORM_ATTRIBUTES = %i[
    meta_title
    meta_description
    product
  ].freeze

  # COLLECTION_FILTERS = {
  #   active: ->(resources) { resources.where(active: true) },
  #   recent: ->(resources) { resources.where("created_at > ?", 30.days.ago) },
  # }.freeze
end
