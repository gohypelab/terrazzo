require "terrazzo/base_dashboard"

class HostDashboard < Terrazzo::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::String,
    name: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
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

  # Override this method to customize how hosts are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(resource)
  #   "Host ##{resource.id}"
  # end
end
