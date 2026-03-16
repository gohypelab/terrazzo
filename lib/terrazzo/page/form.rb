module Terrazzo
  module Page
    class Form < Base
      attr_reader :resource

      def initialize(dashboard, resource)
        super(dashboard, resource.class)
        @resource = resource
      end

      def grouped_attributes(action = nil)
        attrs = dashboard.form_attributes(action)
        normalize_groups(attrs, :form)
      end

      def attributes(action = nil)
        attrs = dashboard.form_attributes(action)
        dashboard.flatten_attributes(attrs).map do |attr|
          dashboard.attribute_type_for(attr).new(attr, nil, :form, resource: resource)
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
