module Terrazzo
  module Field
    class BelongsTo < Associative
      def serialize_value(mode)
        case mode
        when :form
          foreign_key_value
        else
          return nil if data.nil?
          { id: data.id, display: display_name(data) }
        end
      end

      def serializable_options
        opts = {}
        if resource
          collection = resource_options
          if options[:include_blank]
            collection = [["", nil]] + collection
          end
          opts[:resourceOptions] = collection
        end
        opts
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
