module SuperAdmin
  module Field
    class Text < Base
      def serialize_value(mode)
        return data.to_s if data.nil?

        case mode
        when :index
          truncate_length = options.fetch(:truncate, 100)
          data.to_s.truncate(truncate_length)
        else
          data.to_s
        end
      end

      class << self
        def searchable?
          true
        end

        def default_options
          { truncate: 100 }
        end
      end
    end
  end
end
