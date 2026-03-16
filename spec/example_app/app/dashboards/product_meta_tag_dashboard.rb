require "super_admin/base_dashboard"

class ProductMetaTagDashboard < SuperAdmin::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: SuperAdmin::Field::Number,
    meta_title: SuperAdmin::Field::String,
    meta_description: SuperAdmin::Field::String,
    created_at: SuperAdmin::Field::DateTime,
    updated_at: SuperAdmin::Field::DateTime,
    product: SuperAdmin::Field::BelongsTo,
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
end
