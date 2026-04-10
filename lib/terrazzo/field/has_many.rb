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

      def page_records
        @page_records ||= begin
          scope = apply_sorting(data)
          if scope.respond_to?(:page)
            scope.page(current_page).per(per_page).tap { |p| @_paginated = p }
          else
            arr = scope.to_a
            @_total_count = arr.size
            arr[(current_page - 1) * per_page, per_page] || []
          end
        end
      end

      private

      def per_page
        (options[:per_page] || options[:limit] || 5).to_i
      end

      def current_page
        p = options[:_page].to_i
        p < 1 ? 1 : p
      end

      def serialize_show_value
        records = page_records.to_a
        total = @_paginated ? @_paginated.total_count : (@_total_count || records.size)
        total_pages = (total.to_f / per_page).ceil
        total_pages = 1 if total_pages < 1

        col_attrs = options[:collection_attributes] || resolve_default_collection_attributes

        meta = {
          total: total,
          perPage: per_page,
          currentPage: current_page,
          totalPages: total_pages,
        }

        if col_attrs
          { **serialize_with_collection_attributes(records, col_attrs), **meta }
        else
          {
            items: records.map { |r| { id: r.id.to_s, display: display_name(r) } },
            **meta,
          }
        end
      end

      def resolve_default_collection_attributes
        dashboard_class = find_associated_dashboard
        dashboard_class.new.collection_attributes
      rescue NameError
        nil
      end

      def serialize_with_collection_attributes(records, col_attrs)
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

        { headers: headers, rows: rows }
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

      class << self
        def sortable?
          false
        end

        def default_options
          {}
        end

        def permitted_attribute(attr, _options = {})
          { "#{attr.to_s.singularize}_ids" => [] }
        end
      end
    end
  end
end
