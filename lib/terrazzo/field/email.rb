module Terrazzo
  module Field
    class Email < Base
      def serialize_value(_mode)
        data
      end
    end
  end
end
