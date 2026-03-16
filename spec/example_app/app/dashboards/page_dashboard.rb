require "super_admin/base_dashboard"

class PageDashboard < SuperAdmin::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: SuperAdmin::Field::Number,
    title: SuperAdmin::Field::String,
    body: SuperAdmin::Field::Text,
    created_at: SuperAdmin::Field::DateTime,
    updated_at: SuperAdmin::Field::DateTime,
    product: SuperAdmin::Field::BelongsTo,
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
end
