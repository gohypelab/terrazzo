module Terrazzo
  module Field
    class Deferred
      attr_reader :deferred_class, :options

      def initialize(deferred_class, **options)
        @deferred_class = deferred_class
        @options = options
      end

      def new(attribute, data = nil, page = nil, resource: nil, options: {})
        deferred_class.new(
          attribute,
          data,
          page,
          resource: resource,
          options: self.options.merge(options)
        )
      end

      def searchable?
        deferred_class.searchable?
      end

      def sortable?
        deferred_class.sortable?
      end

      def eager_load?
        deferred_class.eager_load?
      end

      def associative?
        deferred_class.associative?
      end

      def field_type
        deferred_class.field_type
      end

      def permitted_attribute(attr, extra_options = {})
        deferred_class.permitted_attribute(attr, self.options.merge(extra_options))
      end

      def with_options(**opts)
        self.class.new(deferred_class, **options.merge(opts))
      end
    end
  end
end
