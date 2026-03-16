module Terrazzo
  module Field
    class Money < Base
      def serialize_value(_mode)
        return nil if data.nil?

        if data.respond_to?(:to_f)
          data.to_f
        else
          data
        end
      end

      def serializable_options
        opts = {}
        opts[:prefix] = options[:prefix] if options.key?(:prefix)
        opts[:suffix] = options[:suffix] if options.key?(:suffix)
        opts[:decimals] = options[:decimals] if options.key?(:decimals)

        # Default to 2 decimal places for currency
        opts[:decimals] ||= 2

        opts
      end

      class << self
        def field_type
          "number"
        end
      end
    end
  end
end
