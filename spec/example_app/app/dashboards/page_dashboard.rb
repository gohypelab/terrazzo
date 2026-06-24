require "terrazzo/base_dashboard"

class PageDashboard < Terrazzo::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::String,
    title: Field::String,
    body: Field::Text,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    product: Field::BelongsTo,
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

  # Overwrite this method to customize how pages are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(resource)
  #   "Page ##{resource.id}"
  # end
end
