require "terrazzo/base_dashboard"

class LogEntryDashboard < Terrazzo::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::String,
    action: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    loggable: Field::Polymorphic.with_options(classes: [Customer, Order]),
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    id
    action
    loggable
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    id
    action
    created_at
    updated_at
    loggable
  ].freeze

  FORM_ATTRIBUTES = %i[
    action
    loggable
  ].freeze

  # COLLECTION_FILTERS = {
  #   active: ->(resources) { resources.where(active: true) },
  #   recent: ->(resources) { resources.where("created_at > ?", 30.days.ago) },
  # }.freeze

  # Overwrite this method to customize how log entries are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(resource)
  #   "LogEntry ##{resource.id}"
  # end
end
