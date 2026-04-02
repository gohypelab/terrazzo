module Terrazzo
  module Field
    class Number < Base
      def serialize_value(mode)
        return data if data.nil? || mode == :form || !options.key?(:multiplier)

        data * options[:multiplier]
      end

      def serializable_options
        opts = {}
        opts[:prefix] = options[:prefix] if options.key?(:prefix)
        opts[:suffix] = options[:suffix] if options.key?(:suffix)
        opts[:decimals] = options[:decimals] if options.key?(:decimals)
        opts
      end
    end
  end
end
