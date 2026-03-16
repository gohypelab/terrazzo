module Terrazzo
  module Field
    class RichText < Base
      def serialize_value(mode)
        return nil if data.nil?

        case mode
        when :index
          data.to_plain_text.truncate(options.fetch(:truncate, 100))
        else
          data.to_s
        end
      end

      class << self
        def searchable?
          false
        end

        def eager_load?
          true
        end

        def default_options
          { truncate: 100 }
        end
      end
    end
  end
end
