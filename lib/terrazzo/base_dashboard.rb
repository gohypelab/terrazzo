require "set"

module Terrazzo
  class BaseDashboard
    Field = Terrazzo::Field

    def attribute_types
      self.class::ATTRIBUTE_TYPES
    end

    def attribute_type_for(attribute)
      type = attribute_types[attribute]
      raise "Unknown attribute: #{attribute}" unless type
      type
    end

    def form_attributes(action = nil)
      case action
      when "new", "create"
        if self.class.const_defined?(:FORM_ATTRIBUTES_NEW)
          self.class::FORM_ATTRIBUTES_NEW
        else
          self.class::FORM_ATTRIBUTES
        end
      when "edit", "update"
        if self.class.const_defined?(:FORM_ATTRIBUTES_EDIT)
          self.class::FORM_ATTRIBUTES_EDIT
        else
          self.class::FORM_ATTRIBUTES
        end
      else
        self.class::FORM_ATTRIBUTES
      end
    end

    def collection_attributes
      attrs = self.class::COLLECTION_ATTRIBUTES
      if attrs.is_a?(Hash)
        attrs.values.flatten
      else
        attrs
      end
    end

    def show_page_attributes
      self.class::SHOW_PAGE_ATTRIBUTES
    end

    def flatten_attributes(attrs)
      attrs.is_a?(Hash) ? attrs.values.flatten : Array(attrs)
    end

    def permitted_attributes(action = nil)
      flatten_attributes(form_attributes(action)).map do |attr|
        attribute_type_for(attr).permitted_attribute(attr, model_class: self.class.model)
      end
    end

    def search_attributes
      attribute_types.select { |_attr, type| type.searchable? }.keys
    end

    def has_many_attributes
      attribute_types.select { |_attr, type| type.field_type == "has_many" }.keys
    end

    def display_resource(resource)
      "#{resource.class.name} ##{resource.id}"
    end

    def attribute_label(attribute, _context = nil)
      attribute.to_s.humanize
    end

    def attribute_hint(_attribute, _context = nil)
      nil
    end

    def collection_cell_options(_attribute, _resource)
      {}
    end

    def collection_includes
      includes_for_attributes(collection_attributes)
    end

    def includes_for_attributes(attributes)
      attribute_set = Set.new(flatten_attributes(attributes))
      model = self.class.model
      attribute_types.each_with_object([]) do |(attr, type), includes|
        next unless attribute_set.include?(attr)
        next unless type.eager_load?
        include_target = type.eager_load_association(attr, model)
        has_association = model.reflect_on_association(include_target)
        has_attachment = model.respond_to?(:reflect_on_attachment) && model.reflect_on_attachment(include_target)
        next unless has_association || has_attachment
        includes << include_target
      end
    end

    def collection_filters
      return {} unless self.class.const_defined?(:COLLECTION_FILTERS)
      self.class::COLLECTION_FILTERS
    end

    def collection_filter_options(_view = nil)
      collection_filters.filter_map do |name, filter|
        next if filter.respond_to?(:arity) && filter.arity > 1

        {
          label: collection_filter_label(name),
          value: name.to_s,
        }
      end
    end

    def collection_filter_label(filter_name)
      filter_name.to_s.humanize
    end

    def collection_toolbar_actions(view = nil)
      return [] unless view && csv_export_enabled?

      [
        {
          label: "Export CSV",
          url: csv_export_url(view),
          sg_visit: false,
        },
      ]
    end

    def layout_actions(_page, _view = nil, resource: nil)
      []
    end

    def csv_export_enabled?
      true
    end

    def csv_attributes
      collection_attributes
    end

    def csv_filename
      "#{self.class.resource_name.pluralize.parameterize}.csv"
    end

    def csv_value(_attribute, value, _resource)
      case value
      when nil
        nil
      when Hash
        csv_hash_value(value)
      when Array
        value.map { |item| csv_value(nil, item, nil) }.join(", ")
      else
        value.to_s
      end
    end

    def empty_collection_message
      "No #{self.class.resource_name.pluralize.downcase} match the current view."
    end

    def navigation_label
      self.class.const_defined?(:NAVIGATION_LABEL, false) ?
        self.class::NAVIGATION_LABEL :
        self.class.resource_name.pluralize
    end

    def navigation_group
      self.class.const_defined?(:NAVIGATION_GROUP, false) ?
        self.class::NAVIGATION_GROUP :
        default_navigation_group
    end

    def navigation_order
      self.class.const_defined?(:NAVIGATION_ORDER, false) ?
        self.class::NAVIGATION_ORDER :
        navigation_label
    end

    def navigation_group_order
      self.class.const_defined?(:NAVIGATION_GROUP_ORDER, false) ?
        self.class::NAVIGATION_GROUP_ORDER :
        navigation_group
    end

    def show_in_navigation?
      self.class.const_defined?(:SHOW_IN_NAVIGATION, false) ?
        self.class::SHOW_IN_NAVIGATION :
        true
    end

    private

    def default_navigation_group
      model_namespace = self.class.model.name.deconstantize
      model_namespace.present? ? model_namespace.underscore.humanize.titleize : "Resources"
    end

    def csv_export_url(view)
      query = view.request.query_parameters.except("_page")
      view.url_for(query.merge(format: :csv, only_path: true))
    end

    def csv_hash_value(value)
      indifferent = value.with_indifferent_access
      return indifferent[:display].to_s if indifferent.key?(:display)
      return "#{indifferent[:count]} #{indifferent[:label]}" if indifferent.key?(:count) && indifferent.key?(:label)

      JSON.generate(value)
    end

    class << self
      def model
        name.chomp("Dashboard").constantize
      end

      def resource_name
        model.model_name.human
      end
    end
  end
end
