require "terrazzo/base_dashboard"

class Blog::TagDashboard < Terrazzo::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::String,
    name: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    posts: Field::HasMany,
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

  # Override this method to customize how tags are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(resource)
  #   "Blog::Tag ##{resource.id}"
  # end
end
