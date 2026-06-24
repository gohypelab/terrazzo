require "terrazzo/base_dashboard"

class CountryDashboard < Terrazzo::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::String,
    code: Field::String,
    name: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
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

  # Overwrite this method to customize how countries are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(resource)
  #   "Country ##{resource.id}"
  # end

  def display_resource(resource)
    resource.name
  end
end
