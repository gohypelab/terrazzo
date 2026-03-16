require "super_admin/base_dashboard"

class HostDashboard < SuperAdmin::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: SuperAdmin::Field::Number,
    name: SuperAdmin::Field::String,
    created_at: SuperAdmin::Field::DateTime,
    updated_at: SuperAdmin::Field::DateTime,
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    id
    name
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    id
    name
    created_at
    updated_at
  ].freeze

  FORM_ATTRIBUTES = %i[
    name
  ].freeze

  # COLLECTION_FILTERS = {
  #   active: ->(resources) { resources.where(active: true) },
  #   recent: ->(resources) { resources.where("created_at > ?", 30.days.ago) },
  # }.freeze
end
