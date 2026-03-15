module SuperAdmin
  module Field
    class Hstore < Base
      class << self
        def sortable?
          false
        end

        def permitted_attribute(attr, _options = {})
          attr.to_sym
        end

        def transform_param(value)
          return {} if value.blank?
          return value if value.is_a?(Hash)

          JSON.parse(value)
        rescue JSON::ParserError
          {}
        end
      end

      def serialize_value(mode)
        hash = data || {}

        case mode
        when :index
          truncate = options[:truncate] || 80
          preview = hash.map { |k, v| "#{k}: #{v}" }.join(", ")
          preview.length > truncate ? "#{preview[0...truncate]}..." : preview
        else
          hash
        end
      end
    end
  end
end
