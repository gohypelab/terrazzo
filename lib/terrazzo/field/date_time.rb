module Terrazzo
  module Field
    class DateTime < Base
      def serialize_value(_mode)
        return nil if data.nil?
        value = if options[:timezone]
          data.in_time_zone(options[:timezone])
        elsif data.respond_to?(:in_time_zone)
          data.in_time_zone
        else
          data
        end
        format = options[:format]
        format ? value.strftime(format) : value.iso8601
      end
    end
  end
end
