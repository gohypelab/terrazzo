require "super_admin/base_dashboard"

class Blog::PostDashboard < SuperAdmin::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: SuperAdmin::Field::Number,
    title: SuperAdmin::Field::String,
    body: SuperAdmin::Field::Text,
    published_at: SuperAdmin::Field::DateTime,
    tags: SuperAdmin::Field::HasMany,
    created_at: SuperAdmin::Field::DateTime,
    updated_at: SuperAdmin::Field::DateTime,
  }.freeze

  COLLECTION_ATTRIBUTES = %i[id title published_at].freeze
  SHOW_PAGE_ATTRIBUTES = %i[id title body published_at tags created_at updated_at].freeze
  FORM_ATTRIBUTES = %i[title body published_at tags].freeze
end
