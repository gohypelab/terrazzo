require "super_admin/base_dashboard"

class SeriesDashboard < SuperAdmin::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: SuperAdmin::Field::Number,
    name: SuperAdmin::Field::String,
  }.freeze

  COLLECTION_ATTRIBUTES = %i[id name].freeze
  SHOW_PAGE_ATTRIBUTES = %i[id name].freeze
  FORM_ATTRIBUTES = %i[name].freeze
end
