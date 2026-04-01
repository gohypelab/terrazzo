require "rails_helper"

RSpec.describe "Admin Customizations", type: :system do
  let!(:country) { Country.find_or_create_by!(code: "US", name: "United States") }

  describe "custom customers index page" do
    let!(:customer) { create(:customer, name: "Test Customer", territory: country) }

    it "renders customers in a card grid instead of a table" do
      visit admin_customers_path

      # Card grid layout — no table element on the customers index
      expect(page).not_to have_css("table")
      # Verify cards are rendering (uses grid layout with card divs)
      expect(page).to have_css(".grid .rounded-lg")
    end

    it "still uses the default table layout for other resources" do
      create(:order, customer: customer)
      visit admin_orders_path

      expect(page).to have_css("table")
    end
  end

  describe "ejected email field with mail icon" do
    let!(:customer) { create(:customer, name: "Icon Test", email: "icon@example.com", territory: country) }

    it "renders a mail icon next to email on the show page" do
      visit admin_customer_path(customer)

      email_link = find("a[href='mailto:icon@example.com']")
      expect(email_link).to have_css("svg")
    end
  end

  describe "ejected boolean field with icons" do
    let!(:customer) { create(:customer, name: "Bool Test", hidden: false, territory: country) }

    it "renders a boolean icon on the show page" do
      visit admin_customer_path(customer)

      # The "Hidden" field row should contain an SVG icon (XCircle for false)
      hidden_row = find("dt", text: "Hidden").find(:xpath, "..").find("dd")
      expect(hidden_row).to have_css("svg")
    end
  end
end
