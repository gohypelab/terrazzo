module SuperAdmin
  module Field
    class DateTime < Base
      def serialize_value(_mode)
        return nil if data.nil?
        data.iso8601
      end
    end
  end
end
