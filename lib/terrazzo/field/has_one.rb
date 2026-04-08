module Terrazzo
  module Field
    class HasOne < Associative
      def serialize_value(mode)
        case mode
        when :form
          data&.id&.to_s
        else
          return nil if data.nil?
          { id: data.id.to_s, display: display_name(data) }
        end
      end

      def serializable_options(page = nil)
        return {} unless page == :form && resource
        { resourceOptions: resource_options }
      end

      class << self
        def sortable?
          false
        end

        def permitted_attribute(attr, _options = {})
          :"#{attr}_id"
        end
      end
    end
  end
end
