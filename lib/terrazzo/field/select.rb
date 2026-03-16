module Terrazzo
  module Field
    class Select < Base
      def serialize_value(_mode)
        data
      end

      def serializable_options
        { selectableOptions: resolve_collection }
      end

      private

      def resolve_collection
        collection = options[:collection]
        return [] unless collection

        raw = if collection.respond_to?(:call)
          collection.call(resource)
        elsif collection.is_a?(::String) || collection.is_a?(Symbol)
          resource.class.public_send(collection).keys
        else
          Array(collection)
        end

        # Ensure tuples [label, value] for the React select component
        raw.map do |item|
          item.is_a?(Array) ? item : [item.to_s.humanize, item]
        end
      end
    end
  end
end
