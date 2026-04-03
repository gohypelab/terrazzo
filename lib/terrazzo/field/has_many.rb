module Terrazzo
  module Field
    class HasMany < Associative
      def serialize_value(mode)
        return nil if data.nil?

        case mode
        when :index
          count = data.size
          label = attribute.to_s.humanize.downcase
          label = label.singularize if count == 1
          { count: count, label: label }
        when :form
          data.map { |r| r.id.to_s }
        when :show
          serialize_show_value
        else
          data.map { |r| { id: r.id.to_s, display: display_name(r) } }
        end
      end

      def serializable_options
        opts = {}
        if resource
          opts[:resourceOptions] = resource_options
        end
        opts
      end

      class << self
        def sortable?
          false
        end

        def default_options
          { limit: 5 }
        end

        def permitted_attribute(attr, _options = {})
          { "#{attr.to_s.singularize}_ids" => [] }
        end
      end

      private

      def serialize_show_value
        limit = options.fetch(:limit, 5)
        records = apply_sorting(data)
        all_records = records.to_a
        total = all_records.size
        col_attrs = options[:collection_attributes] || resolve_default_collection_attributes

        if col_attrs
          serialize_with_collection_attributes(all_records, col_attrs, total, limit)
        else
          {
            items: all_records.map { |r| { id: r.id.to_s, display: display_name(r) } },
            total: total,
            initialLimit: limit
          }
        end
      end

      def resolve_default_collection_attributes
        dashboard_class = find_associated_dashboard
        dashboard_class.new.collection_attributes
      rescue NameError
        nil
      end

      def serialize_with_collection_attributes(records, col_attrs, total, limit)
        dashboard_class = find_associated_dashboard

        headers = col_attrs.map do |attr|
          { attribute: attr.to_s, label: attr.to_s.humanize }
        end

        items = records.map do |record|
          columns = col_attrs.map do |attr|
            field = dashboard_class.new.attribute_type_for(attr).new(attr, nil, :index, resource: record)
            {
              attribute: attr.to_s,
              fieldType: field.field_type,
              value: field.serialize_value(:index)
            }
          end
          { id: record.id.to_s, columns: columns }
        end

        {
          headers: headers,
          items: items,
          total: total,
          initialLimit: limit
        }
      end

      def resource_options
        return [] unless associated_class
        scope = if options[:scope].is_a?(Proc)
          options[:scope].call(associated_class)
        elsif options[:scope]
          associated_class.public_send(options[:scope])
        else
          associated_class.all
        end
        scope = scope.includes(*options[:includes]) if options.key?(:includes)
        pk = association_primary_key
        dashboard = associated_dashboard
        scope.map { |r| [dashboard ? dashboard.display_resource(r) : display_name(r), r.public_send(pk).to_s] }
      end

      def apply_sorting(records)
        sort_by = options[:sort_by]
        return records unless sort_by

        direction = options.fetch(:direction, :asc)
        records.reorder(sort_by => direction)
      end

      def find_associated_dashboard
        klass = associated_class
        "#{klass.name}Dashboard".constantize
      end
    end
  end
end
