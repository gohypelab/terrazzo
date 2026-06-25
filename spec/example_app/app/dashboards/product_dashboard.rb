require "terrazzo/base_dashboard"

class ProductDashboard < Terrazzo::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::String,
    name: Field::String,
    price: Field::Number,
    description: Field::Text,
    image_url: Field::Url,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    slug: Field::String,
    release_year: Field::Number.with_options(suffix: "AD"),
    banner: Field::RichText,
    line_items: Field::HasMany,
    pages: Field::HasMany,
    product_meta_tag: Field::HasOne,
    document: Field::Asset,
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    id
    name
    price
    description
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    id
    name
    price
    description
    image_url
    created_at
    updated_at
    slug
    release_year
    banner
    line_items
    pages
    product_meta_tag
    document
  ].freeze

  FORM_ATTRIBUTES = %i[
    name
    price
    description
    image_url
    slug
    release_year
    banner
    line_items
    pages
    product_meta_tag
    document
  ].freeze

  # COLLECTION_FILTERS = {
  #   active: ->(resources) { resources.where(active: true) },
  #   recent: ->(resources) { resources.where("created_at > ?", 30.days.ago) },
  # }.freeze

  # Override this method to customize how products are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(resource)
  #   "Product ##{resource.id}"
  # end

  def display_resource(resource)
    resource.name
  end
end
