require "super_admin/base_dashboard"

class LogEntryDashboard < SuperAdmin::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: SuperAdmin::Field::Number,
    action: SuperAdmin::Field::String,
    created_at: SuperAdmin::Field::DateTime,
    updated_at: SuperAdmin::Field::DateTime,
    loggable: SuperAdmin::Field::Polymorphic.with_options(classes: ["Customer", "Order"]),
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
end
