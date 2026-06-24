require "terrazzo/base_dashboard"

class PaymentDashboard < Terrazzo::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    order: Field::BelongsTo,
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    id
    order
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    id
    created_at
    updated_at
    order
  ].freeze

  FORM_ATTRIBUTES = %i[
    order
  ].freeze

  # COLLECTION_FILTERS = {
  #   active: ->(resources) { resources.where(active: true) },
  #   recent: ->(resources) { resources.where("created_at > ?", 30.days.ago) },
  # }.freeze

  # Overwrite this method to customize how payments are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(resource)
  #   "Payment ##{resource.id}"
  # end
end
