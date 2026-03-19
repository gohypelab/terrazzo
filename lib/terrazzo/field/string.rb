module Terrazzo
  module Field
    class String < Base
      def serialize_value(mode)
        return data.to_s if data.nil?

        case mode
        when :index
          truncate_length = options.fetch(:truncate, 50)
          data.to_s.truncate(truncate_length)
        else
          data.to_s
        end
      end

      class << self
        def default_options
          { truncate: 50 }
        end
      end
    end
  end
end
