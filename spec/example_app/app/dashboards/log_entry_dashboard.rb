require "terrazzo/base_dashboard"

class LogEntryDashboard < Terrazzo::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Terrazzo::Field::Number,
    action: Terrazzo::Field::String,
    created_at: Terrazzo::Field::DateTime,
    updated_at: Terrazzo::Field::DateTime,
    loggable: Terrazzo::Field::Polymorphic.with_options(classes: ["Customer", "Order"]),
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
