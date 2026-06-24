module Admin
  class OrdersController < ApplicationController
    def invoice
      redirect_to admin_orders_path, notice: "Printing invoice"
    end
  end
end
