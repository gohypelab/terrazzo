module Terrazzo
  module Field
    class DateTime < Base
      def serialize_value(_mode)
        return nil if data.nil?
        format = options[:format]
        format ? data.strftime(format) : data.iso8601
      end
    end
  end
end
