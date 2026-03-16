require "super_admin/base_dashboard"

class Blog::PostDashboard < SuperAdmin::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: SuperAdmin::Field::Number,
    title: SuperAdmin::Field::String,
    published_at: SuperAdmin::Field::DateTime,
    body: SuperAdmin::Field::Text,
    created_at: SuperAdmin::Field::DateTime,
    updated_at: SuperAdmin::Field::DateTime,
    tags: SuperAdmin::Field::HasMany,
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    id
    title
    published_at
    body
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    id
    title
    published_at
    body
    created_at
    updated_at
    tags
  ].freeze

  FORM_ATTRIBUTES = %i[
    title
    published_at
    body
    tags
  ].freeze

  # COLLECTION_FILTERS = {
  #   active: ->(resources) { resources.where(active: true) },
  #   recent: ->(resources) { resources.where("created_at > ?", 30.days.ago) },
  # }.freeze
end
