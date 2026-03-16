require "terrazzo/base_dashboard"

class CountryDashboard < Terrazzo::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Terrazzo::Field::Number,
    code: Terrazzo::Field::String,
    name: Terrazzo::Field::String,
    created_at: Terrazzo::Field::DateTime,
    updated_at: Terrazzo::Field::DateTime,
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    id
    code
    name
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    id
    code
    name
    created_at
    updated_at
  ].freeze

  FORM_ATTRIBUTES = %i[
    code
    name
  ].freeze

  # COLLECTION_FILTERS = {
  #   active: ->(resources) { resources.where(active: true) },
  #   recent: ->(resources) { resources.where("created_at > ?", 30.days.ago) },
  # }.freeze
end
