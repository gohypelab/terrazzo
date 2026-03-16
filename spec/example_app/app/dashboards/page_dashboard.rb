require "terrazzo/base_dashboard"

class PageDashboard < Terrazzo::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Terrazzo::Field::Number,
    title: Terrazzo::Field::String,
    body: Terrazzo::Field::Text,
    created_at: Terrazzo::Field::DateTime,
    updated_at: Terrazzo::Field::DateTime,
    product: Terrazzo::Field::BelongsTo,
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    id
    title
    body
    product
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    id
    title
    body
    created_at
    updated_at
    product
  ].freeze

  FORM_ATTRIBUTES = %i[
    title
    body
    product
  ].freeze

  # COLLECTION_FILTERS = {
  #   active: ->(resources) { resources.where(active: true) },
  #   recent: ->(resources) { resources.where("created_at > ?", 30.days.ago) },
  # }.freeze
end
