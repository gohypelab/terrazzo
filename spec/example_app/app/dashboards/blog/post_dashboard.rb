require "terrazzo/base_dashboard"

class Blog::PostDashboard < Terrazzo::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Terrazzo::Field::Number,
    title: Terrazzo::Field::String,
    published_at: Terrazzo::Field::DateTime,
    body: Terrazzo::Field::Text,
    created_at: Terrazzo::Field::DateTime,
    updated_at: Terrazzo::Field::DateTime,
    tags: Terrazzo::Field::HasMany,
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    id
    title
    published_at
    body
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    id
    title
    published_at
    body
    created_at
    updated_at
    tags
  ].freeze

  FORM_ATTRIBUTES = %i[
    title
    published_at
    body
    tags
  ].freeze

  # COLLECTION_FILTERS = {
  #   active: ->(resources) { resources.where(active: true) },
  #   recent: ->(resources) { resources.where("created_at > ?", 30.days.ago) },
  # }.freeze
end
