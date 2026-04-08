module Terrazzo
  module Field
    class BelongsTo < Associative
      def serialize_value(mode)
        case mode
        when :form
          foreign_key_value&.to_s
        else
          return nil if data.nil?
          { id: data.id.to_s, display: display_name(data) }
        end
      end

      def serializable_options(page = nil)
        return {} unless page == :form && resource
        collection = ordered_resource_options
        if options[:include_blank]
          collection = [["", nil]] + collection
        end
        { resourceOptions: collection }
      end

      class << self
        def permitted_attribute(attr, options = {})
          if options[:foreign_key]
            options[:foreign_key].to_sym
          elsif options[:model_class]
            reflection = options[:model_class].reflect_on_association(attr)
            reflection ? reflection.foreign_key.to_sym : :"#{attr}_id"
          else
            :"#{attr}_id"
          end
        end
      end

      private

      def ordered_resource_options
        return [] unless associated_class
        scope = if options[:scope].is_a?(Proc)
          options[:scope].call(associated_class)
        elsif options[:scope]
          associated_class.public_send(options[:scope])
        else
          associated_class.all
        end
        scope = scope.reorder(options[:order]) if options[:order]
        pk = association_primary_key
        dashboard = associated_dashboard
        scope.map { |r| [dashboard ? dashboard.display_resource(r) : display_name(r), r.public_send(pk).to_s] }
      end

      def foreign_key_value
        return nil unless resource

        reflection = resource.class.reflect_on_association(attribute)
        if reflection
          resource.public_send(reflection.foreign_key)
        else
          resource.public_send(:"#{attribute}_id")
        end
      end
    end
  end
end
