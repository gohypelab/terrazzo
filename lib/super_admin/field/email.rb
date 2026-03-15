module SuperAdmin
  module Field
    class Email < Base
      def serialize_value(_mode)
        data
      end

      class << self
        def searchable?
          true
        end
      end
    end
  end
end
