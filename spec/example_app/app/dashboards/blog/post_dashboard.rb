require "terrazzo/base_dashboard"

class Blog::PostDashboard < Terrazzo::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::String,
    title: Field::String,
    published_at: Field::DateTime,
    body: Field::Text,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    tags: Field::HasMany,
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

  # Overwrite this method to customize how posts are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(resource)
  #   "Blog::Post ##{resource.id}"
  # end
end
