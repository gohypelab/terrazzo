require "rails_helper"

RSpec.describe "Admin Line Items", type: :system do
  let!(:country) { Country.find_or_create_by!(code: "US", name: "United States") }
  let!(:customer) { create(:customer, territory: country) }
  let!(:order) { create(:order, customer: customer) }
  let!(:product) { create(:product) }
  let!(:line_item) { create(:line_item, order: order, product: product, unit_price: 29.99, quantity: 2) }

  describe "show" do
    it "renders the line item details" do
      visit admin_line_item_path(line_item)

      expect(page).to have_content("29.99")
      expect(page).to have_content("2")
    end
  end

  describe "edit" do
    it "renders the edit line item form" do
      visit edit_admin_line_item_path(line_item)

      expect(page).to have_field("Quantity", with: "2")
    end

    it "updates the line item" do
      visit edit_admin_line_item_path(line_item)

      fill_in "Quantity", with: "5"
      click_button "Save"

      expect(page).to have_content("5")
    end
  end

  describe "destroy" do
    it "deletes the line item from the show page" do
      visit admin_line_item_path(line_item)

      accept_confirm { click_button "Delete" }

      expect(page).to have_current_path(admin_root_path)
    end
  end
end
