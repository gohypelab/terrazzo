require "super_admin/base_dashboard"

class Blog::TagDashboard < SuperAdmin::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: SuperAdmin::Field::Number,
    name: SuperAdmin::Field::String,
    created_at: SuperAdmin::Field::DateTime,
    updated_at: SuperAdmin::Field::DateTime,
    posts: SuperAdmin::Field::HasMany,
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    id
    name
    posts
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    id
    name
    created_at
    updated_at
    posts
  ].freeze

  FORM_ATTRIBUTES = %i[
    name
    posts
  ].freeze

  # COLLECTION_FILTERS = {
  #   active: ->(resources) { resources.where(active: true) },
  #   recent: ->(resources) { resources.where("created_at > ?", 30.days.ago) },
  # }.freeze
end
