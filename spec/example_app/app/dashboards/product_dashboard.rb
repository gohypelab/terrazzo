require "super_admin/base_dashboard"

class ProductDashboard < SuperAdmin::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: SuperAdmin::Field::Number,
    name: SuperAdmin::Field::String,
    price: SuperAdmin::Field::Number.with_options(prefix: "$", decimals: 2),
    description: SuperAdmin::Field::Text,
    image_url: SuperAdmin::Field::Url,
    created_at: SuperAdmin::Field::DateTime,
    updated_at: SuperAdmin::Field::DateTime,
    slug: SuperAdmin::Field::String,
    release_year: SuperAdmin::Field::Select.with_options(collection: (2000..Date.today.year).to_a.reverse),
    banner: SuperAdmin::Field::RichText,
    line_items: SuperAdmin::Field::HasMany,
    pages: SuperAdmin::Field::HasMany,
    product_meta_tag: SuperAdmin::Field::HasOne,
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
