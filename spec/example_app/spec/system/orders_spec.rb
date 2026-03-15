require "rails_helper"

RSpec.describe "Admin Orders", type: :system do
  let!(:country) { Country.find_or_create_by!(code: "US", name: "United States") }
  let!(:customer) { create(:customer, name: "Alice Johnson", territory: country) }
  let!(:order) { create(:order, customer: customer, address_city: "Springfield") }

  describe "index" do
    it "renders the orders list" do
      visit admin_orders_path

      expect(page).to have_content("Springfield")
    end
  end

  describe "show" do
    it "renders the order details" do
      visit admin_order_path(order)

      expect(page).to have_content("Springfield")
      expect(page).to have_content("123 Main St")
    end
  end
end
