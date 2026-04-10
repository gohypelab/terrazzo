module Terrazzo
  module Field
    class HasMany < Associative
      attr_accessor :show_offset

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

      # Returns only the records that were serialized for the show page.
      # Used by the view template to build hasManyRowExtras for only the
      # visible records instead of iterating over the entire association.
      def show_records
        @show_records || data&.to_a || []
      end

      def serializable_options(page = nil)
        opts = {}
        if page == :form && resource
          opts[:resourceOptions] = resource_options
        end
        if options.key?(:render_actions)
          opts[:renderActions] = options[:render_actions]
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
        offset = show_offset || 0
        records = apply_sorting(data)

        if limit && limit > 0
          if !records.is_a?(Array) && records.respond_to?(:limit)
            total = records.size
            limited = records.offset(offset).limit(limit).to_a
          else
            all = records.to_a
            total = all.size
            limited = all.slice(offset, limit) || []
          end
        else
          limited = records.to_a
          total = limited.size
        end

        @show_records = limited
        col_attrs = options[:collection_attributes] || resolve_default_collection_attributes

        if col_attrs
          serialize_with_collection_attributes(limited, col_attrs, total, limit, offset)
        else
          {
            items: limited.map { |r| { id: r.id.to_s, display: display_name(r) } },
            total: total,
            initialLimit: limit,
            offset: offset
          }
        end
      end

      def resolve_default_collection_attributes
        dashboard_class = find_associated_dashboard
        dashboard_class.new.collection_attributes
      rescue NameError
        nil
      end

      def serialize_with_collection_attributes(records, col_attrs, total, limit, offset = 0)
        dashboard_class = find_associated_dashboard

        headers = col_attrs.map do |attr|
          { attribute: attr.to_s, label: attr.to_s.humanize }
        end

        rows = records.map do |record|
          cells = col_attrs.map do |attr|
            field = dashboard_class.new.attribute_type_for(attr).new(attr, nil, :index, resource: record)
            {
              attribute: attr.to_s,
              fieldType: field.field_type,
              value: field.serialize_value(:index)
            }
          end
          { id: record.id.to_s, cells: cells }
        end

        {
          headers: headers,
          rows: rows,
          total: total,
          initialLimit: limit,
          offset: offset
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

        if records.respond_to?(:reorder)
          records.reorder(sort_by => direction)
        else
          sorted = records.sort_by { |r| r.public_send(sort_by) }
          direction.to_sym == :desc ? sorted.reverse : sorted
        end
      end

      def find_associated_dashboard
        klass = associated_class
        "#{klass.name}Dashboard".constantize
      end
    end
  end
end
