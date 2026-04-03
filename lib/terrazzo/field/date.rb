module Terrazzo
  module Field
    class Date < Base
      def serialize_value(_mode)
        return nil if data.nil?
        value = if options[:timezone]
          data.in_time_zone(options[:timezone]).to_date
        elsif data.respond_to?(:in_time_zone)
          data.in_time_zone.to_date
        else
          data
        end
        format = options[:format]
        format ? value.strftime(format) : value.to_s
      end
    end
  end
end
