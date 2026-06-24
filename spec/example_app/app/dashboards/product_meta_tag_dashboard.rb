require "terrazzo/base_dashboard"

class ProductMetaTagDashboard < Terrazzo::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::String,
    meta_title: Field::String,
    meta_description: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    product: Field::BelongsTo,
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

  # Overwrite this method to customize how product meta tags are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(resource)
  #   "ProductMetaTag ##{resource.id}"
  # end
end
