require "terrazzo/base_dashboard"

class SeriesDashboard < Terrazzo::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::String,
    name: Field::String.with_options(searchable: true),
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    id
    name
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    id
    name
  ].freeze

  FORM_ATTRIBUTES = %i[
    name
  ].freeze

  COLLECTION_FILTERS = {
    starts_with_alpha: ->(resources) { resources.where("name LIKE ?", "Alpha%") },
  }.freeze

  def collection_toolbar_actions(view)
    super + [
      {
        label: "Series audit",
        url: view.admin_series_index_path(audit: "1"),
        sg_visit: false,
      },
    ]
  end

  def layout_actions(page, view, resource: nil)
    return [] unless page == :index

    [
      {
        label: "Series guide",
        url: view.admin_series_index_path(anchor: "series-guide"),
        sg_visit: false,
      },
    ]
  end

  def collection_row_options(resource)
    return {} unless resource.name.start_with?("Alpha")

    {
      class_name: "bg-muted/40",
      tone: "highlight",
    }
  end

  def collection_header_options(attribute)
    return {} unless attribute == :name

    {
      class_name: "w-64",
      priority: "primary",
    }
  end

  # Override this method to customize how series are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(resource)
  #   "Series ##{resource.id}"
  # end
end
