module Terrazzo
  module Field
    class Url < Base
      def serialize_value(_mode)
        data
      end
    end
  end
end
