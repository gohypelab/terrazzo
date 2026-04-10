module Terrazzo
  module Page
    class Show < Base
      attr_reader :resource

      def initialize(dashboard, resource, has_many_params: {})
        super(dashboard, resource.class)
        @resource = resource
        @has_many_params = has_many_params || {}
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
          build_field(attr, :show)
        end
      end

      private

      def build_field(attr, mode)
        extra = @has_many_params[attr.to_sym] || {}
        dashboard.attribute_type_for(attr).new(attr, nil, mode, resource: resource, options: extra)
      end

      def normalize_groups(attrs, mode)
        if attrs.is_a?(Hash)
          attrs.map do |group_name, fields|
            {
              name: group_name,
              fields: fields.map { |attr| build_field(attr, mode) }
            }
          end
        else
          [{
            name: "",
            fields: attrs.map { |attr| build_field(attr, mode) }
          }]
        end
      end
    end
  end
end
