module Terrazzo
  module Field
    class Polymorphic < Associative
      def serialize_value(mode)
        case mode
        when :form
          return nil if data.nil?
          { type: data.class.name, id: data.id.to_s }
        else
          return nil if data.nil?
          { id: data.id.to_s, display: display_name(data), type: data.class.name }
        end
      end

      def serializable_options(page = nil)
        return {} unless page == :form
        classes = options[:classes] || []
        order = options[:order]
        grouped = classes.each_with_object({}) do |klass, hash|
          klass = klass.constantize if klass.is_a?(::String)
          scope = order ? klass.order(order) : klass.all
          hash[klass.name] = scope.map { |r| [display_name(r), r.id.to_s] }
        end
        { groupedOptions: grouped }
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
