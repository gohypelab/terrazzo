module SuperAdmin
  class BaseDashboard
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

    def display_resource(resource)
      "#{resource.class.name} ##{resource.id}"
    end

    def collection_includes
      attribute_types.select { |_attr, type| type.eager_load? }.keys
    end

    def collection_filters
      return {} unless self.class.const_defined?(:COLLECTION_FILTERS)
      self.class::COLLECTION_FILTERS
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
