module Terrazzo
  module Field
    class Time < Base
      def serialize_value(_mode)
        return nil if data.nil?
        format = options[:format]
        format ? data.strftime(format) : data.to_s
      end
    end
  end
end
