module SuperAdmin
  module Field
    class Time < Base
      def serialize_value(_mode)
        return nil if data.nil?
        data.to_s
      end
    end
  end
end
