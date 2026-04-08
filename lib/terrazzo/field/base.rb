module Terrazzo
  module Field
    class Base
      attr_reader :attribute, :data, :page, :resource, :options

      def initialize(attribute, data = nil, page = nil, resource: nil, options: {})
        @attribute = attribute
        @data = data
        @page = page
        @resource = resource
        @options = self.class.default_options.merge(options)
        @data = resolve_data if resource && data.nil?
      end

      def field_type
        self.class.field_type
      end

      def serialize_value(mode)
        data
      end

      def serializable_options(page = nil)
        {}
      end

      def required?
        return false unless resource

        resource.class.validators_on(attribute).any? do |v|
          v.is_a?(ActiveModel::Validations::PresenceValidator)
        end
      end

      def form_input_attributes(param_key)
        opts = options.dup
        opts[:model_class] ||= resource.class if resource
        perm = self.class.permitted_attribute(attribute, opts)
        case perm
        when Hash
          key = perm.keys.first.to_s
          { name: "#{param_key}[#{key}][]", id: "#{param_key}_#{key}" }
        when Array
          # polymorphic returns [type_attr, id_attr]
          {
            name: "#{param_key}[#{perm.last}]",
            id: "#{param_key}_#{perm.last}",
            typeName: "#{param_key}[#{perm.first}]"
          }
        else
          { name: "#{param_key}[#{perm}]", id: "#{param_key}_#{perm}" }
        end
      end

      ABSTRACT_FIELD_CLASSES = %w[Base Associative Deferred].freeze

      class << self
        def field_type
          # Walk ancestors to find the nearest concrete Terrazzo::Field class.
          # This ensures custom subclasses (e.g. HasManyScopedField < HasMany)
          # resolve to the parent's field_type for FieldRenderer mapping.
          ancestors.each do |klass|
            next unless klass.is_a?(Class) && klass < Terrazzo::Field::Base
            next if klass == Terrazzo::Field::Base
            if klass.name&.start_with?("Terrazzo::Field::")
              demod = klass.name.demodulize
              next if ABSTRACT_FIELD_CLASSES.include?(demod)
              return demod.underscore
            end
          end
          name.demodulize.underscore
        end

        def searchable?
          false
        end

        def sortable?
          true
        end

        def eager_load?
          false
        end

        def associative?
          false
        end

        def with_options(**opts)
          Deferred.new(self, **opts)
        end

        def permitted_attribute(attr, _options = {})
          attr.to_sym
        end

        def transform_param(value)
          value
        end

        def default_options
          {}
        end
      end

      private

      def resolve_data
        resource.try(attribute)
      end
    end
  end
end
