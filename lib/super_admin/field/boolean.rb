module SuperAdmin
  module Field
    class Boolean < Base
      def serialize_value(_mode)
        data
      end
    end
  end
end
