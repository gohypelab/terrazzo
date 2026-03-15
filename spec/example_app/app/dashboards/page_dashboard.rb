require "super_admin/base_dashboard"

class PageDashboard < SuperAdmin::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: SuperAdmin::Field::Number,
    title: SuperAdmin::Field::String,
    body: SuperAdmin::Field::Text,
    product: SuperAdmin::Field::BelongsTo,
    created_at: SuperAdmin::Field::DateTime,
    updated_at: SuperAdmin::Field::DateTime,
  }.freeze

  COLLECTION_ATTRIBUTES = %i[id title product].freeze
  SHOW_PAGE_ATTRIBUTES = %i[id title body product created_at updated_at].freeze
  FORM_ATTRIBUTES = %i[title body product].freeze
end
