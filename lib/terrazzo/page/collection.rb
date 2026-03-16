module Terrazzo
  module Page
    class Collection < Base
      attr_reader :order

      def initialize(dashboard, resource_class, order: Order.new)
        super(dashboard, resource_class)
        @order = order
      end

      def attribute_names
        dashboard.collection_attributes
      end

      def ordered_by?(attr)
        order.ordered_by?(attr)
      end

      def order_params_for(attr)
        order.order_params_for(attr)
      end

      def sort_direction_for(attr)
        order.ordered_by?(attr) ? order.direction.to_s : nil
      end
    end
  end
end
