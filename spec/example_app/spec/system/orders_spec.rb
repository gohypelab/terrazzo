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

  describe "pagination" do
    before do
      25.times { create(:order, customer: customer) }
    end

    it "renders pagination controls on page 1" do
      visit admin_orders_path

      expect(page).to have_content("Rows per page")
      expect(page).to have_link("Next")
      expect(page).to have_css('[aria-label="Go to previous page"].pointer-events-none')
    end

    it "renders page 2 when navigated directly" do
      visit admin_orders_path(_page: 2)

      expect(page).to have_link("Previous")
      expect(page).to have_css('[aria-label="Go to next page"].pointer-events-none')
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
