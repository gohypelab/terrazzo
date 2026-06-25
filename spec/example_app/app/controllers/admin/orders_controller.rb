module Admin
  class OrdersController < ApplicationController
    def bulk_ship
      orders = Order.where(id: Array(params[:ids]))
      orders.update_all(shipped_at: Time.current)

      redirect_to admin_orders_path,
        notice: "Marked #{orders.count} #{'order'.pluralize(orders.count)} shipped"
    end

    def invoice
      redirect_to admin_orders_path, notice: "Printing invoice"
    end
  end
end
