module SuperAdmin
  module Field
    class Polymorphic < Associative
      def serialize_value(mode)
        case mode
        when :form
          return nil if data.nil?
          { type: data.class.name, id: data.id }
        else
          return nil if data.nil?
          { id: data.id, display: display_name(data), type: data.class.name }
        end
      end

      def serializable_options
        opts = {}
        classes = options[:classes] || []
        opts[:groupedOptions] = classes.each_with_object({}) do |klass, hash|
          klass = klass.constantize if klass.is_a?(::String)
          hash[klass.name] = klass.all.map { |r| [display_name(r), r.id] }
        end
        opts
      end

      class << self
        def sortable?
          false
        end

        def permitted_attribute(attr, _options = {})
          [:"#{attr}_type", :"#{attr}_id"]
        end
      end
    end
  end
end
