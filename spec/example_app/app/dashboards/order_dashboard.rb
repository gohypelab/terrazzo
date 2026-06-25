require "terrazzo/base_dashboard"

class OrderDashboard < Terrazzo::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::String,
    address_line_one: Field::String,
    address_line_two: Field::String,
    address_city: Field::String,
    address_state: Field::String,
    address_zip: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    shipped_at: Field::DateTime,
    customer: Field::BelongsTo,
    line_items: Field::HasMany,
    payments: Field::HasMany,
    log_entries: Field::HasMany,
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    id
    address_line_one
    address_line_two
    address_city
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    id
    address_line_one
    address_line_two
    address_city
    address_state
    address_zip
    created_at
    updated_at
    shipped_at
    customer
    line_items
    payments
    log_entries
  ].freeze

  FORM_ATTRIBUTES = %i[
    address_line_one
    address_line_two
    address_city
    address_state
    address_zip
    shipped_at
    customer
    line_items
    payments
    log_entries
  ].freeze

  # COLLECTION_FILTERS = {
  #   active: ->(resources) { resources.where(active: true) },
  #   recent: ->(resources) { resources.where("created_at > ?", 30.days.ago) },
  # }.freeze

  # Override this method to customize how orders are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(resource)
  #   "Order ##{resource.id}"
  # end

  def collection_item_actions(resource, view)
    [
      { label: "View Order", url: view.admin_order_path(resource) },
      { label: "Edit", url: view.edit_admin_order_path(resource) },
      { label: "Invoice", url: view.invoice_admin_order_path(resource), sg_visit: false },
    ]
  end
end
