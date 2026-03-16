require "terrazzo/base_dashboard"

class Blog::TagDashboard < Terrazzo::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Terrazzo::Field::Number,
    name: Terrazzo::Field::String,
    created_at: Terrazzo::Field::DateTime,
    updated_at: Terrazzo::Field::DateTime,
    posts: Terrazzo::Field::HasMany,
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    id
    name
    posts
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    id
    name
    created_at
    updated_at
    posts
  ].freeze

  FORM_ATTRIBUTES = %i[
    name
    posts
  ].freeze

  # COLLECTION_FILTERS = {
  #   active: ->(resources) { resources.where(active: true) },
  #   recent: ->(resources) { resources.where("created_at > ?", 30.days.ago) },
  # }.freeze
end
