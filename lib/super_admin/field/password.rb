module SuperAdmin
  module Field
    class Password < Base
      MASKED = "\u2022" * 8

      def serialize_value(mode)
        case mode
        when :form
          nil
        else
          data.present? ? MASKED : nil
        end
      end
    end
  end
end
