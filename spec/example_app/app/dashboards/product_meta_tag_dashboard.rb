require "super_admin/base_dashboard"

class ProductMetaTagDashboard < SuperAdmin::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: SuperAdmin::Field::Number,
    product: SuperAdmin::Field::BelongsTo,
    meta_title: SuperAdmin::Field::String,
    meta_description: SuperAdmin::Field::String,
    created_at: SuperAdmin::Field::DateTime,
    updated_at: SuperAdmin::Field::DateTime,
  }.freeze

  COLLECTION_ATTRIBUTES = %i[id product meta_title].freeze
  SHOW_PAGE_ATTRIBUTES = %i[id product meta_title meta_description created_at updated_at].freeze
  FORM_ATTRIBUTES = %i[product meta_title meta_description].freeze
end
