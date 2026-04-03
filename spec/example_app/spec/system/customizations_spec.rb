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

  describe "collection_item_actions customization for orders" do
    let!(:customer) { create(:customer, name: "Alice Johnson", territory: country) }
    let!(:order) { create(:order, customer: customer) }

    it "shows custom action buttons on the orders index" do
      visit admin_orders_path

      expect(page).to have_link("View Order")
      expect(page).to have_link("Edit")
      expect(page).to have_link("Invoice")
      expect(page).not_to have_link("Show")
      expect(page).not_to have_link("Destroy")
    end

    it "shows custom action buttons in the has_many orders table on customer#show" do
      visit admin_customer_path(customer)

      within("table", match: :first) do
        expect(page).to have_link("View Order")
        expect(page).to have_link("Invoice")
      end
    end

    it "invoice action redirects with a flash notice" do
      visit admin_orders_path
      click_link "Invoice", match: :first

      expect(page).to have_content("Printing invoice")
    end

    it "non-order resources still use default actions" do
      create(:customer, name: "Other Customer", territory: country)
      visit admin_customers_path

      # Custom card grid — no table, no action links from default helper
      expect(page).not_to have_link("View Order")
      expect(page).not_to have_link("Invoice")
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
