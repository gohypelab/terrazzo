module Terrazzo
  module Page
    class Show < Base
      attr_reader :resource

      def initialize(dashboard, resource)
        super(dashboard, resource.class)
        @resource = resource
      end

      def page_title
        dashboard.display_resource(resource)
      end

      def grouped_attributes
        attrs = dashboard.show_page_attributes
        normalize_groups(attrs, :show)
      end

      def attributes
        attrs = dashboard.show_page_attributes
        dashboard.flatten_attributes(attrs).map do |attr|
          dashboard.attribute_type_for(attr).new(attr, nil, :show, resource: resource)
        end
      end

      private

      def normalize_groups(attrs, mode)
        if attrs.is_a?(Hash)
          attrs.map do |group_name, fields|
            {
              name: group_name,
              fields: fields.map { |attr| dashboard.attribute_type_for(attr).new(attr, nil, mode, resource: resource) }
            }
          end
        else
          [{
            name: "",
            fields: attrs.map { |attr| dashboard.attribute_type_for(attr).new(attr, nil, mode, resource: resource) }
          }]
        end
      end
    end
  end
end
