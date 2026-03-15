module SuperAdmin
  module Field
    class Number < Base
      def serialize_value(_mode)
        data
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
