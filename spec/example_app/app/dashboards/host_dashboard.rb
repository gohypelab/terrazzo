require "terrazzo/base_dashboard"

class HostDashboard < Terrazzo::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Terrazzo::Field::Number,
    name: Terrazzo::Field::String,
    created_at: Terrazzo::Field::DateTime,
    updated_at: Terrazzo::Field::DateTime,
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
