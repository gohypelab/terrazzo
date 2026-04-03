require "active_support/number_helper"

module Terrazzo
  module Field
    class Number < Base
      def serialize_value(mode)
        return data if data.nil? || mode == :form

        value = options.key?(:multiplier) ? data * options[:multiplier] : data

        if options[:format]
          formatter = options[:format][:formatter]
          formatter_options = options[:format][:formatter_options].to_h
          ActiveSupport::NumberHelper.try(formatter, value, **formatter_options) || value
        else
          value
        end
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
