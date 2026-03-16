require "terrazzo/base_dashboard"

class ProductDashboard < Terrazzo::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Terrazzo::Field::Number,
    name: Terrazzo::Field::String,
    price: Terrazzo::Field::Number.with_options(prefix: "$", decimals: 2),
    description: Terrazzo::Field::Text,
    image_url: Terrazzo::Field::Url,
    created_at: Terrazzo::Field::DateTime,
    updated_at: Terrazzo::Field::DateTime,
    slug: Terrazzo::Field::String,
    release_year: Terrazzo::Field::Select.with_options(collection: (2000..Date.today.year).to_a.reverse),
    banner: Terrazzo::Field::RichText,
    line_items: Terrazzo::Field::HasMany,
    pages: Terrazzo::Field::HasMany,
    product_meta_tag: Terrazzo::Field::HasOne,
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
  ].freeze

  FORM_ATTRIBUTES = %i[
    name
    price
    description
    image_url
    release_year
    product_meta_tag
  ].freeze

  # COLLECTION_FILTERS = {
  #   active: ->(resources) { resources.where(active: true) },
  #   recent: ->(resources) { resources.where("created_at > ?", 30.days.ago) },
  # }.freeze
end
