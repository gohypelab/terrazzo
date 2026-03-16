module Terrazzo
  module Field
    class HasMany < Associative
      def serialize_value(mode)
        return nil if data.nil?

        case mode
        when :index
          data.size
        when :form
          data.map(&:id)
        when :show
          serialize_show_value
        else
          data.map { |r| { id: r.id, display: display_name(r) } }
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
        total = data.size
        col_attrs = options[:collection_attributes]

        records = if limit && limit > 0
          data.respond_to?(:limit) ? data.limit(limit) : data.first(limit)
        else
          data
        end

        if col_attrs
          serialize_with_collection_attributes(records, col_attrs, total, limit)
        else
          {
            items: records.map { |r| { id: r.id, display: display_name(r) } },
            total: total,
            hasMore: limit && limit > 0 ? total > limit : false
          }
        end
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
          { id: record.id, columns: columns }
        end

        {
          headers: headers,
          items: items,
          total: total,
          hasMore: limit && limit > 0 ? total > limit : false
        }
      end

      def find_associated_dashboard
        klass = associated_class
        "#{klass.name}Dashboard".constantize
      end
    end
  end
end
