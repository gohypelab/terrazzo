require "super_admin/base_dashboard"

class Blog::TagDashboard < SuperAdmin::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: SuperAdmin::Field::Number,
    name: SuperAdmin::Field::String,
    posts: SuperAdmin::Field::HasMany,
    created_at: SuperAdmin::Field::DateTime,
    updated_at: SuperAdmin::Field::DateTime,
  }.freeze

  COLLECTION_ATTRIBUTES = %i[id name].freeze
  SHOW_PAGE_ATTRIBUTES = %i[id name posts created_at updated_at].freeze
  FORM_ATTRIBUTES = %i[name posts].freeze
end
