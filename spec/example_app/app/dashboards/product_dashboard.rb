require "super_admin/base_dashboard"

class ProductDashboard < SuperAdmin::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: SuperAdmin::Field::Number,
    name: SuperAdmin::Field::String,
    price: SuperAdmin::Field::Number.with_options(prefix: "$", decimals: 2),
    description: SuperAdmin::Field::Text,
    image_url: SuperAdmin::Field::Url,
    slug: SuperAdmin::Field::String,
    release_year: SuperAdmin::Field::Select.with_options(
      collection: (2000..Date.today.year).to_a.reverse
    ),
    line_items: SuperAdmin::Field::HasMany,
    pages: SuperAdmin::Field::HasMany,
    product_meta_tag: SuperAdmin::Field::HasOne,
    created_at: SuperAdmin::Field::DateTime,
    updated_at: SuperAdmin::Field::DateTime,
  }.freeze

  COLLECTION_ATTRIBUTES = %i[id name price slug product_meta_tag].freeze
  SHOW_PAGE_ATTRIBUTES = %i[id name price description image_url slug release_year line_items pages product_meta_tag created_at updated_at].freeze
  FORM_ATTRIBUTES = %i[name price description image_url release_year product_meta_tag].freeze
end
